--Setting the data types of columns
--ALTER TABLE dbo.CovidDeaths ALTER COLUMN total_cases float 
--AlTER TABLE dbo.CovidDeaths ALTER COLUMN total_deaths float
--ALTER TABLE dbo.CovidVaccinations ALTER COLUMN new_vaccinations float
SELECT * FROM CovidDeaths ORDER BY 3,4
SELECT * FROM CovidVaccinations ORDER BY 3,4

--Overview of data
SELECT location,date,total_cases,new_cases,total_deaths,population FROM CovidDeaths ORDER BY 1,2

--Creating a Temporary Table
DROP TABLE if exists #DeathData
SELECT location,date,total_cases,total_deaths,ROUND((total_deaths/total_cases)*100,2) AS DeathRatio,population INTO #DeathData FROM CovidDeaths 
WHERE continent IS NOT NULL AND (total_cases>total_deaths)

--STATISTICS

--Covid Patients Count and Percentage
--According to location
SELECT location,MAX(total_cases) AS Total_Cases,MAX(population) AS Population,ROUND((MAX(total_cases/population))*100,2) AS 'CovidPatients%'
FROM #DeathData GROUP BY location ORDER BY [CovidPatients%] DESC
--According to date
SELECT date,SUM(new_cases) AS TotalCases,SUM(new_deaths) AS TotalDeaths, ROUND((SUM(new_deaths)/SUM(new_cases))*100,2) AS DeathPercentage
FROM CovidDeaths WHERE continent IS NOT NULL GROUP BY date HAVING SUM(new_cases) <> 0 ORDER BY 1

--Covid Spread in Pakistan
SELECT location,MAX(total_cases) AS Total_Cases,MAX(population) AS Population,ROUND((MAX(total_cases/population))*100,2) AS 'CovidPatients%'
FROM #DeathData WHERE location='Pakistan' GROUP BY location ORDER BY [CovidPatients%] DESC

--Total Deaths around the world
SELECT location,MAX(total_deaths) AS Total_Deaths FROM #DeathData GROUP BY location ORDER BY 2 DESC

--Death Percentage of COVID Patients in each Country
SELECT location,ROUND((max(total_deaths/total_cases))*100,2) AS DeathPercentage FROM #DeathData GROUP BY location ORDER BY 2 desc

--Total Cases in Each Continent
SELECT continent,MAX(total_cases) AS TotalCases FROM CovidDeaths WHERE	continent IS NOT NULL AND location NOT LIKE ('%income') 
GROUP BY continent order by 2 desc

--Looking at total population vs vaccinations
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations FROM CovidDeaths AS d JOIN CovidVaccinations AS v 
ON d.date= v.date AND d.location= v.location WHERE v.continent IS NOT NULL AND new_vaccinations IS NOT NULL ORDER BY 2,3

--Looking at Vaccination Percentage
DROP TABLE IF EXISTS #VaccinationPercentage
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(new_vaccinations) 
OVER (Partition BY d.location Order By d.location,d.date) AS TotalPeopleVaccinated INTO #VaccinationPercentage FROM CovidDeaths AS d JOIN CovidVaccinations AS v 
ON d.date= v.date AND d.location= v.location

SELECT *,ROUND((TotalPeopleVaccinated/population)*100,2) AS 'Vaccination%' FROM #VaccinationPercentage

--Creating a view
CREATE VIEW VaccinationPercentage AS
SELECT d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(new_vaccinations) 
OVER (Partition BY d.location Order By d.location,d.date) AS TotalPeopleVaccinated FROM CovidDeaths AS d JOIN CovidVaccinations AS v 
ON d.date= v.date AND d.location= v.location

SELECT * FROM VaccinationPercentage
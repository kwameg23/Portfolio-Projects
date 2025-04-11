
SELECT *
FROM [Portfolio Project]..['covid-deaths$']
ORDER BY 3,4



---- selecting the data needed

--SELECT location,date,total_cases,new_cases,total_deaths,population
--FROM dbo.['covid-deaths$']
--ORDER BY 1,2



-- Looking at total cases vs total deaths

SELECT location,date,total_cases,new_cases,total_deaths,(total_deaths / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM [Portfolio Project]..['covid-deaths$']
where location like 'Kenya'
ORDER BY 1,2
--This shows the likelihood of dying if you contract covid in your country



--Looking at total cases vs population

SELECT location,date,population,total_cases,(total_cases / population)*100 as PopulationPercentage
FROM [Portfolio Project]..['covid-deaths$']
WHERE location like 'Kenya'
ORDER BY 1,2
--shows what percentage of the population got covid



--Lokking at countries with thw Highest infection rate compared to Population


SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases / population))*100 as PercentagePopulationInfected
FROM [Portfolio Project]..['covid-deaths$']
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc


-- Countries with the highest Death count per Population

SELECT location, MAX(cast (total_deaths as int)) as TotalDeathCount
FROM [Portfolio Project]..['covid-deaths$']
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc




--GLOBAL NUMBERS

SELECT date, SUM(COALESCE(new_cases, 0)) AS Total_cases , SUM(COALESCE(CAST(new_deaths AS INT), 0)) AS Total_Deaths, 
COALESCE(SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0), 0) AS DeathPercentage
FROM [Portfolio Project]..['covid-deaths$']
--where location like 'Kenya'
WHERE continent is not null
GROUP BY date
ORDER BY date

SELECT  SUM(COALESCE(new_cases, 0)) AS Total_cases , SUM(COALESCE(CAST(new_deaths AS INT), 0)) AS Total_Deaths, 
COALESCE(SUM(CAST(new_deaths AS INT)) / NULLIF(SUM(new_cases), 0), 0) AS DeathPercentage
FROM [Portfolio Project]..['covid-deaths$']
--where location like 'Kenya'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2




SELECT *
FROM [Portfolio Project]..['covid-deaths$'] dea
JOIN [Portfolio Project]..['covid-vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date



--Looking at Total Population vs Vaccination

SELECT dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(COALESCE(TRY_CAST(vac.new_vaccinations AS BIGINT), 0)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS Rolling_Vaccinations
FROM [Portfolio Project]..['covid-deaths$'] dea
JOIN [Portfolio Project]..['covid-vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


--USE CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, Rolling_Vaccinations) as (
SELECT dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(COALESCE(TRY_CAST(vac.new_vaccinations AS BIGINT), 0)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS Rolling_Vaccinations
FROM [Portfolio Project]..['covid-deaths$'] dea
JOIN [Portfolio Project]..['covid-vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)

SELECT*,(Rolling_Vaccinations/population)*100
FROM PopvsVac


--TEMP TABLE

DROP TABLE IF EXISTS #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated (
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_Vaccinations numeric)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(COALESCE(TRY_CAST(vac.new_vaccinations AS BIGINT), 0)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS Rolling_Vaccinations
FROM [Portfolio Project]..['covid-deaths$'] dea
JOIN [Portfolio Project]..['covid-vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT*,(Rolling_Vaccinations/Population)*100 as PercentageVaccinated
FROM #PercentagePopulationVaccinated


--Creating View to store data for later visualization

CREATE VIEW PercentagePopulationVaccinated AS
SELECT dea.continent ,dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(COALESCE(TRY_CAST(vac.new_vaccinations AS BIGINT), 0)) 
        OVER (PARTITION BY dea.location ORDER BY dea.date) AS Rolling_Vaccinations
FROM [Portfolio Project]..['covid-deaths$'] dea
JOIN [Portfolio Project]..['covid-vaccinations$'] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentagePopulationVaccinated


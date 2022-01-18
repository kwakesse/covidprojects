--looking at the total cases vs total deaths
-- the likelihood of dying if you contract COVID in a given country
SELECT location, date, total_cases, total_deaths, population
FROM PortfolioProjects_Covid..CovidDeaths
ORDER BY 1,2

-- Looking at the total cases vs total deaths

SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS totalDeathToCases
FROM PortfolioProjects_Covid..CovidDeaths
WHERE location LIKE '%States%'
ORDER BY 1,2

-- looking at total cases vs population
SELECT location, date, total_cases, population, (total_cases/population)*100 As TotalCaseToPopulation
FROM PortfolioProjects_Covid..CovidDeaths
WHERE location LIKE '%States%'
ORDER BY 1,2

-- What country has the highest infection rate per population
SELECT location,MAX(total_cases) AS HighestInfectionCounts, MAX(total_cases/population)*100 As PercentPopInfectected
FROM PortfolioProjects_Covid..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopInfectected DESC;

-- Country with Highest death count per population
SELECT location,MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProjects_Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC;


--BREAKING BY CONTINENT
SELECT continent, MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProjects_Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- showing the continent with the highest deathcount
SELECT continent,MAX(CAST(total_deaths AS bigint)) AS TotalDeathCount
FROM PortfolioProjects_Covid..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DailyTotalGlobalDeathsToCases
FROM PortfolioProjects_Covid..CovidDeaths
WHERE continent IS NoT NULL
GROUP BY date
ORDER BY 1,2

--Looking at total global death to date
SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DailyTotalGlobalDeathsToCases
FROM PortfolioProjects_Covid..CovidDeaths
WHERE continent IS NoT NULL
ORDER BY 1,2

--JOINING TABLES
--looking at total population vs vaccination
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations 
FROM PortfolioProjects_Covid..CovidDeaths d
JOIN PortfolioProjects_Covid..CovidVaccinations v
	ON d.location=v.location
	AND d.date=v.date
WHERE d.continent IS NOT NULL
ORDER by 2,3;

--Cummulative Vaccination 
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT (int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS CummulativeCount
FROM PortfolioProjects_Covid..CovidDeaths d
JOIN PortfolioProjects_Covid..CovidVaccinations v
	ON d.location=v.location
	AND d.date=v.date
WHERE d.continent IS NOT NULL
ORDER by 2,3;

-- USE CTE is used be able to use an new created aggregate column ie CummlativeCount in other calculations
With PopvsVac (continent, location, date, population, new_vaccinations, CummulativeCount)
as
(
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT (int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS CummulativeCount
FROM PortfolioProjects_Covid..CovidDeaths d
JOIN PortfolioProjects_Covid..CovidVaccinations v
	ON d.location=v.location
	AND d.date=v.date
WHERE d.continent IS NOT NULL
--ORDER by 2,3
)
SELECT *, (CummulativeCount/population)*100 AS CummulativeCountPerPop
FROM PopvsVac;


--USE CTE OR TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar(255), 
location nvarchar (255), 
date datetime, 
Population NUMERIC, 
new_vaccinations NUMERIC, 
CummulativeCount NUMERIC)

----INSERT INTO
----SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
----SUM(CONVERT (int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS CummulativeCount
----FROM PortfolioProjects_Covid..CovidDeaths d
--JOIN PortfolioProjects_Covid..CovidVaccinations v
--	ON d.location=v.location
--	AND d.date=v.date
--WHERE d.continent IS NOT NULL
----ORDER by 2,3
--)
--SELECT *, (CummulativeCount/population)*100 AS CummulativeCountPerPop
--FROM PopvsVac;

--CREATING VIEWS TO STORE DATA FOR LATER VISUALIZATIONS
CREATE VIEW PercentPopulationVaccinated AS
SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations, 
SUM(CONVERT (int, v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS CummulativeCount
FROM PortfolioProjects_Covid..CovidDeaths d
JOIN PortfolioProjects_Covid..CovidVaccinations v
	ON d.location=v.location
	AND d.date=v.date
WHERE d.continent IS NOT NULL
--ORDER by 2,3 ;

SELECT *
FROM PercentPopulationVaccinated;
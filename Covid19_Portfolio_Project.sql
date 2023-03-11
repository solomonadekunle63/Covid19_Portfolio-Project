/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT
  *
FROM covid_portfolio_project.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4;


-- Select Data that we are going to be starting with

SELECT
  Location,
  date,
  total_cases,
  new_cases,
  total_deaths,
  population
FROM covid_portfolio_project.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From covid_portfolio_project.CovidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From covid_portfolio_project.CovidDeaths
-- Where location like '%states%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From covid_portfolio_project.CovidDeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


-- Countries with Highest Death Count per Population

SELECT
  Location,
  MAX(CAST(Total_deaths AS float)) AS TotalDeathCount
FROM covid_portfolio_project.CovidDeaths
-- Where location like '%states%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as float)) as TotalDeathCount
From covid_portfolio_project.CovidDeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by TotalDeathCount desc;



-- GLOBAL NUMBERS

SELECT
  SUM(new_cases) AS total_cases,
  SUM(CAST(new_deaths AS float)) AS total_deaths,
  SUM(CAST(new_deaths AS float)) / SUM(New_Cases) * 100 AS DeathPercentage
FROM covid_portfolio_project.CovidDeaths
-- Where location like '%states%'
WHERE continent IS NOT NULL
-- Group By date
ORDER BY 1, 2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid_portfolio_project.CovidDeaths dea
JOIN covid_portfolio_project.CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS (SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid_portfolio_project.CovidDeaths dea
JOIN covid_portfolio_project.CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--order by 2,3
)
SELECT
  *,
  (RollingPeopleVaccinated / Population) * 100
FROM PopvsVac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated 
(
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
  SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
  --, (RollingPeopleVaccinated/population)*100
  FROM covid_portfolio_project.CovidDeaths dea
  JOIN covid_portfolio_project.CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
-- where dea.continent is not null 
-- order by 2,3

SELECT
  *,
  (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated
AS
SELECT
  dea.continent,
  dea.location,
  dea.date,
  dea.population,
  vac.new_vaccinations,
  SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM covid_portfolio_project.CovidDeaths dea
JOIN covid_portfolio_project.CovidVaccinations vac
  ON dea.location = vac.location
  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL

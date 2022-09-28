SELECT * FROM portfolio_project..CovidDeathsFinal$
order by 3,4

SELECT * FROM portfolio_project..CovidVaccination$
WHERE continent is not null
order by 3,4

-- [NOTE: This data I have imported, the names of the csv files have interchanged unexpectedly. I am actually using the the Covid Vaccination csv file for Covid Death csv file and vice-a-versa.]

-- Facts and Data related to Covid Deaths:

-- Select the data that we are going to be using in this project:

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portfolio_project..CovidVaccination$ WHERE continent is not null
order by Location, date

-- Looking at the total Cases vs Total Deaths in a specific county:
-- Showing the likelihood of dying if you contract covid in your country.

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolio_project..CovidVaccination$ WHERE continent is not null
order by Location, date

-- Looking for total Cases vs Total Deaths in United States of America: 

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolio_project..CovidVaccination$ WHERE Location like '%states%' and continent is not null
order by Location, date

-- Looking at the Total Cases vs Population:
-- Shows what percentage of population have got covid

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentagePopulationInfected
FROM portfolio_project..CovidVaccination$ WHERE Location like '%states%' and continent is not null
order by Location, date

-- Looking at Countries with Highest Infection Rate Compared to Population:

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX(total_cases/population)*100 AS PercentagePopulationInfected
FROM portfolio_project..CovidVaccination$ WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC 

-- Showing the Counries with Highest Death Count per Population:

SELECT Location, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM portfolio_project..CovidVaccination$ WHERE continent is not null
GROUP BY Location, Population
ORDER BY TotalDeathCount DESC 

-- Now Let's get all the insights from data continent wise:

-- Showing continents with the highest death count:

SELECT continent, MAX(CAST(total_deaths as int)) AS TotalDeathCount
FROM portfolio_project..CovidVaccination$ WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC 

-- GLOBAL NUMBERS:
-- Shows the total cases, total deaths and then the percentage of people died due to covid in the world.
SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as int)) AS total_deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage --, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM portfolio_project..CovidVaccination$ WHERE continent is not null
--GROUP BY date
order by 1,2

-- Facts and Data related to Covid Vaccinations:

SELECT * FROM portfolio_project..CovidVaccination$ vac 
JOIN portfolio_project..CovidDeathsFinal$ dea
ON dea.location = vac.location
and dea.date = vac.date

-- Looking at Total Population vs Vaccinations:
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated, 
FROM portfolio_project..CovidVaccination$ dea 
JOIN portfolio_project..CovidDeathsFinal$ as vac 
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not NULL
ORDER BY 2,3

-- USE CTE:
WITH PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS ( 
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM portfolio_project..CovidVaccination$ dea 
JOIN portfolio_project..CovidDeathsFinal$ as vac 
ON dea.location = vac.location and dea.date = vac.date
WHERE dea.continent is not NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/Population)*100 FROM PopvsVac

-- Creating View to store data for later visualizations:
CREATE VIEW PercentPopulationVaccinatedFinal as
SELECT dea.continent, dea.location, dea.date, vac.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) 
AS RollingPeopleVaccinated 
--, (RollingPeopleVaccinated/Population)*100
FROM portfolio_project..CovidDeathsFinal$ dea
JOIN portfolio_project..CovidVaccination$ vac
	ON dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null
-- ORDER BY 2,3


SELECT * FROM PercentPopulationVaccinatedFinal
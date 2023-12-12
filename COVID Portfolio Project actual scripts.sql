
SELECT *
FROM SQLPortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--SELECT *
--FROM SQLPortfolioProject..CovidVaccinations
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SQLPortfolioProject..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying from covid in nigeria
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM SQLPortfolioProject..CovidDeaths
where location like '%nigeria%'
and continent is not null
order by 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of the population got infected
SELECT location, date, population, total_cases, (total_cases/population)*100 AS PopulationPercentage
FROM SQLPortfolioProject..CovidDeaths
where continent is not null
--where location like '%nigeria%'
order by 1,2


-- Looking at Countries with highest Infection Rates compared to Population

SELECT location, population, MAX(total_cases) as MaxInfectioncount, MAX((total_cases/population))*100 
AS InfectionPercentage
FROM SQLPortfolioProject..CovidDeaths
where continent is not null
--where location like '%nigeria%'
group by location, population
order by InfectionPercentage DESC

-- Looking at Countries with Highest Death Count compared to population


SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLPortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by location
order by TotalDeathCount DESC

--LET'S BREAK DOWN BY CONTINENT

-- Showing the continents with highest death counts per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM SQLPortfolioProject..CovidDeaths
--where location like '%nigeria%'
where continent is not null
group by continent
order by TotalDeathCount DESC

-- Looking at Continents with highest Infection Rates compared to Population

SELECT continent, MAX(total_cases) as MaxInfectioncount, MAX((total_cases/population))*100 
AS InfectionPercentagePerContinent
FROM SQLPortfolioProject..CovidDeaths
where continent is not null
--where location like '%nigeria%'
group by continent
order by InfectionPercentagePerContinent DESC

-- Shows likelihood of dying from covid in Africa

SELECT continent, date, (total_deaths/total_cases)*100 AS DeathPercentagePerContinent
FROM SQLPortfolioProject..CovidDeaths
where continent is not null
and continent like '%africa%'
order by DeathPercentagePerContinent desc


-- GLOBAL NUMBERS

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100as GlobalDeathPercentage 
FROM SQLPortfolioProject..CovidDeaths
--where location like '%nigeria%'
WHERE continent is not null
--GROUP BY date
order by 1,2

-- Total Population vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 1,2,3


--USE CTE
--TotalPopulation vs Vaccination percentage

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(250),
Location nvarchar(250),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM SQLPortfolioProject..CovidDeaths dea
JOIN SQLPortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated

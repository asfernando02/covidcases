SELECT *
FROM coviddeaths
where continent is not null
order by 3,4;



-- Select data we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
WHERE continent is not null
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM coviddeaths
WHERE location like '%states%'
and continent is not null
order by 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected
FROM coviddeaths
-- WHERE location like '%states%'
order by 1,2;


-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected
FROM coviddeaths
-- WHERE location like '%states%'
GROUP BY Location, Population
order by PercentPopulationInfected desc;


-- Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM coviddeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
order by TotalDeathCount desc;

-- BREAKING THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths as float)) as TotalDeathCount
FROM coviddeaths
-- WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
order by TotalDeathCount desc;

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage
FROM coviddeaths
-- WHERE location like '%states%'
WHERE continent is not null
-- Group By date
order by 1,2;


-- Total Population vs. Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
order by 2,3;

-- USE CTE

With PopvsVac (Continent, Location, `Date`, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- TEMP TABLE
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS PercentPopulationVaccinated;
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
Continent VARCHAR(255),
Location VARCHAR(255),
`Date` date,
Population decimal,
New_vaccinations decimal,
RollingPeopleVaccinated decimal
)
;



UPDATE covidvaccinations
SET `date` = CASE
    WHEN `date` LIKE '%/%/%' THEN STR_TO_DATE(`date`, '%m/%d/%Y')
    WHEN `date` LIKE '' THEN NULL
END;

UPDATE coviddeaths
SET `date` = CASE
    WHEN `date` LIKE '%/%/%' THEN STR_TO_DATE(`date`, '%m/%d/%Y')
    WHEN `date` LIKE '' THEN NULL
END;

ALTER TABLE covidvaccinations 
ADD COLUMN new_vaccinations_decimal DECIMAL(10, 2) DEFAULT NULL;

UPDATE covidvaccinations
SET new_vaccinations_decimal =
    CAST(NULLIF(TRIM(new_vaccinations), '') AS DECIMAL(10,2));


INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_decimal
, SUM(vac.new_vaccinations_decimal) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
-- , RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
-- WHERE dea.continent is not null
-- order by 2,3
;

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated;




-- Creating View to store data for later visualization


Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
-- , RollingPeopleVaccinated/population)*100
FROM coviddeaths dea
JOIN covidvaccinations vac
	On dea.location = vac.location
    and dea.date = vac.date
WHERE dea.continent is not null
;

SELECT 
    *
FROM
    PercentPopulationVaccinated

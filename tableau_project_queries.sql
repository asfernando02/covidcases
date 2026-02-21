-- Queries used for Tableau Project



-- 1. 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as decimal)) as total_deaths, SUM(cast(new_deaths as decimal))/SUM(New_Cases)*100 as DeathPercentage
FROM coviddeaths
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


-- Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
-- From PortfolioProject..CovidDeaths
-- Where location like '%states%'
-- where location = 'World' 
-- Group By date
-- order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe
SELECT continent, SUM(CAST(new_deaths AS float)) as TotalDeathCount
FROM coviddeaths
-- Where location like '%states%'
WHERE continent IS NOT NULL
AND location NOT IN ('World', 'European Union', 'International')
GROUP BY continent
ORDER BY TotalDeathCount DESC;


-- 3.

SELECT Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
FROM coviddeaths
-- Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc;


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddeaths
-- Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;





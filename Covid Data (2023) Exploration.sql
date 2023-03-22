select *
from Portfolio..CovidDeaths
where continent is not null
order by 3,4

select continent, location, date, total_cases, new_cases, total_deaths, population
from Portfolio..CovidDeaths
where continent is not null
order by 1,2,3

-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in Vietnam
select continent, location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from Portfolio..CovidDeaths
where location like '%Vietnam%'
and continent is not null
order by 1,2,3

-- Total Cases vs Population
-- Shows what percentage of population got Covid in Vietname
select continent, location, date, population, total_cases,  (total_cases/population)*100 PercentPopulationInfected
from Portfolio..CovidDeaths
where location like '%Vietnam%'
and continent is not null
order by 1,2

-- Countries with highest infection rate compared to population
select continent,location, population, max(total_cases) highestinfestcount,  max((total_cases/population))*100 PercentPopulationInfected
from Portfolio..CovidDeaths
where continent is not null
group by continent, location, population
order by PercentPopulationInfected desc

-- Countries with highest death count per population 
select continent, location, max(cast(total_deaths as int)) TotalDeathCount
from Portfolio..CovidDeaths
where continent is not null
group by continent, location
order by continent, location, TotalDeathCount desc

--BY CONTINENT

-- Continents with the highest death count per population
select continent, max(cast(total_deaths as int)) TotalDeathCount
from Portfolio..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- GLOBAL NUMBERS

select sum(new_cases) total_cases, sum(cast(new_deaths as int)) toal_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0) *100 DeathNewRatio
from Portfolio..CovidDeaths
where continent is not null
order by 1,2


-- Total Population vs Vaccinations
with PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as (
select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(float,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) RollingPeopleVaccinated
from Portfolio..CovidDeaths d
join Portfolio..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
)

select *, (RollingPeopleVaccinated/population)*100
from PopvsVac



-- Create View to store data for later visualization

Create View PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(CONVERT(float,v.new_vaccinations)) over (partition by d.location order by d.location, d.date) RollingPeopleVaccinated
from Portfolio..CovidDeaths d
join Portfolio..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null

Create View GloabalDeaths as
select sum(new_cases) total_cases, sum(cast(new_deaths as int)) toal_deaths, sum(cast(new_deaths as int))/nullif(sum(new_cases),0) *100 DeathNewRatio
from Portfolio..CovidDeaths
where continent is not null
order by 1,2

Create View Total_Death_Count as
select location, max(cast(total_deaths as int)) TotalDeathCount
from Portfolio..CovidDeaths
where continent is not null
and location is not in ('World', 'European Union', 'International')
group by location

Create View InfectionCount as
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From Portfolio..CovidDeaths
Group by Location, Population
order by PercentPopulationInfected desc

Create View InfectionCount_bydate as
Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by Location, Population, date
order by PercentPopulationInfected desc

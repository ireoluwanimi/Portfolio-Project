Select *
From PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations$
--order by 3,4

--Select Data that we are going to be using 
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths$
order by 1,2

--look at total cases vs total deaths 
-- shows the likelihood of dying from Covid in the specified country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where location like '%canada%'
order by 1,2

-- looking at the totalcases versus population 
-- shows what percentage of the population got Covid
Select Location, date, total_cases, Population, (total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
where location like '%canada%'
order by 1,2

---what country has the highest infection rate compared to population 
Select Location, Population, max(total_cases) as HighestInfectionCount, MAX(total_cases/Population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths$
--where location like '%canada%'
where continent is not null
Group by Location, Population
order by PercentPopulationInfected desc

--showing the countries with the highest death count or population
Select Location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%canada%'
where continent is not null
Group by Location
order by TotalDeathCount desc

---check for null - looks correct
Select location, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%canada%'
where continent is null
Group by location
order by TotalDeathCount desc

---By continent
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%canada%'
where continent is not null
Group by continent
order by TotalDeathCount desc

---Showing the continent with highest death count
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths$
--where location like '%canada%'
--where continent is not null
Group by continent
order by TotalDeathCount desc

---global numbers
Select continent, SUM(new_cases) as total_cases1, SUM(cast(new_deaths as int)) as total_deaths1, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--where location like '%canada%'
where continent is not null
Group by continent 
order by 1,2

Select SUM(new_cases) as total_cases1, SUM(cast(new_deaths as int)) as total_deaths1, SUM(cast(new_deaths as int))/SUM(New_cases)*100 as DeathPercentage
--total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
--where location like '%canada%'
where continent is not null
--Group by continent 
order by 1,2

select *
From PortfolioProject..CovidVaccinations$

---loking at total population vs vaccinations 
--let join the two table together 

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
--or SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location)
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3 

--use CTE 
With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVac)
as 
(
---no of columns in CTE must be the same no of columns after select
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
--or SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location)
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVac/population)*100
From PopvsVac

---temp table 
Drop table if exists #PercentPopulationVaccinated 
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVac numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
--or SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location)
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVac/population)*100
From #PercentPopulationVaccinated

--creating view store data later for visualitation 
create view PercentPopulationVac as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVac
--or SUM(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location)
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
--the view created above can be queried 
select *
from PercentPopulationVac
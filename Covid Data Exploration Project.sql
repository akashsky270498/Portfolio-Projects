select * 
from PortfolioProject.. CovidDeaths
where continent is not null
order by 1,2




--select *
--from PortfolioProject.. covidvaccinations
--order by 3,4

--Select the Data that we are going to work out:-
Select Location, date, total_cases, new_cases, total_deaths,population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

//this line was added by me Ajaykumar
--Looking at Total Cases v/s Total Deaths
--Shows likelihood of Dying if you contracted Covid in your Country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject.. coviddeaths
where Location like  '%India%' and continent is not null
order by 1,2

--Looking at total Cases v/s Population
--Shows what percentage of Population got Covid

Select Location, date, Population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject.. covidDeaths
--where Location like '%India%'
where continent is not null
order by 1,2

--Looking at Countries with Highest Infection Rate Compared to Population.

Select Location, Population, MAX(total_cases) as Highest_Infection_Count,  MAX((total_cases/Population))*100 as 
PercentPopulationInfected
from PortfolioProject.. CovidDeaths
--where Location like '%India%'
where continent is not null
group by Location,Population
order by PercentPopulationInfected desc 

--Showing Countries with Highest Death Count per Population 
--cast means changing datatype from nvarchar to int

select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.. CovidDeaths 
--where location like '%India%'
where continent is not null
group by Location
order by TotalDeathCount desc

--Lets Break things by continents

--Showing Continents with Highest Death Count per Population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject.. CovidDeaths
--where location = '%India%'
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int)) / SUM(new_cases)*100
as
DeathPercentage
from PortfolioProject.. CovidDeaths
--where continent is like '%India%'
where continent is not null
--group by date
order by 1,2

--Looking at total Populations v/s Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from PortfolioProject.. CovidDeaths as dea
join PortfolioProject.. CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--USE CTE
with PopVsVac (continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.Location, dea.Date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from PortfolioProject.. CovidDeaths as dea
join PortfolioProject.. CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentagePeopleVaccinated
from PopVsVac


--TEMP TABLE


DROP table if exists #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT into #PercentPopulationVaccinated
select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.Date) 
as RollingPeopleVaccinated
from PortfolioProject.. CovidDeaths as dea
join
PortfolioProject.. CovidVaccinations as vac
	on dea.Location = vac.Location
	and dea.Date = vac.Date
--where continent is not null
--Order by 2,3

select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated



--Creating View to Store Data for later Vizualization

CREATE view PercentPopulationVaccinated as

select dea.Continent, dea.Location, dea.Date, dea.Population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location,dea.Date) 
as RollingPeopleVaccinated
from PortfolioProject.. CovidDeaths as dea
join
PortfolioProject.. CovidVaccinations as vac
	on dea.Location = vac.Location
	and dea.Date = vac.Date
where dea.continent is not null
--Order by 2,3

select * from PercentPopulationVaccinated

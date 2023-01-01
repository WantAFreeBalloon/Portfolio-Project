Select *
From CovidProject.dbo.CovidDeaths$
where continent is not null
order by 3,4

--select *
--from SQLProject.dbo.CovidVaccinations$
--order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from CovidProject.dbo.CovidDeaths$
where continent is not null
order by 1, 2

--Looking at Total Cases vs Total Deaths
--Shows the liklihood of dying if u got covid
Select Location, date, total_cases, total_deaths,(Total_deaths/Total_cases)*100 AS deathPercentage
from CovidProject.dbo.CovidDeaths$
where location like '%states%' 
order by 1, 2

--Looking at Total Cases vs Population
--Shows the liklihood of population that have covid
Select Location, date, total_cases, population,(Total_cases/population)*100 AS PositivePercentage
from CovidProject.dbo.CovidDeaths$
where location like '%states%' 
order by 1, 2

--Showing country with the highest infection rate
select Location, max(total_cases) as HighestInfectionCount, max((Total_cases/population)*100) as MaxInfectedRate
from CovidProject.dbo.CovidDeaths$
where continent is not null
group by Location, Population
order by MaxInfectedRate DESC

--Showing countries with highest Death Count per population
Select Location, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidProject.dbo.CovidDeaths$
where continent is not null
group by Location
order by TotalDeathCount DESC



--Now Let's break things down by continent
Select location, max(cast(Total_deaths as int)) as TotalDeathCount
from CovidProject.dbo.CovidDeaths$
where continent is null
group by location
order by TotalDeathCount DESC


-- Global Numbers
Select sum(new_cases), sum(cast(new_deaths as int)), (sum(cast(new_deaths as int))/sum(new_cases))*100 AS deathPercentage
from CovidProject.dbo.CovidDeaths$
where continent is not null
--group by date
order by 1,2



-- USE CTE
With PopvsVac(Continent, Location, Date, population, new_vaccinations, RollingPeopleVaccinated) as (
	select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		sum(convert(int, v.new_vaccinations)) over(partition by d.location, d.date) as RollingPeopleVaccinated
		--(RollingPeopleVaccinated/population)*100
	from CovidProject.dbo.CovidDeaths$ d
		join
		CovidProject.dbo.CovidVaccinations$ v
		on d.date = v.date and d.location = v.location
	where d.continent is not null
	--order by 2, 3

)
select 
*, (RollingPeopleVaccinated/population)*100
from PopvsVac


-----------------------------------------------------------
-- TEMP TABLE
drop table if exists #PercentPopulationVaccined
create table #PercentPopulationVaccined
(
	continent nvarchar(255),
	location nvarchar(255),
	Date datetime,
	population numeric,
	new_vaccinations numeric,
	RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccined
select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		sum(convert(int, v.new_vaccinations)) over(partition by d.location, d.date) as RollingPeopleVaccinated
		--(RollingPeopleVaccinated/population)*100
	from CovidProject.dbo.CovidDeaths$ d
		join
		CovidProject.dbo.CovidVaccinations$ v
		on d.date = v.date and d.location = v.location
	where d.continent is not null

select *, (RollingPeopleVaccinated/population)*100 from #PercentPopulationVaccined

-- Creating View to store data for later visualizations
use CovidProject
drop view if exists PercentPopulationVaccined

create view PercentPopulationVaccined as
	select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
		sum(convert(int, v.new_vaccinations)) over(partition by d.location, d.date) as RollingPeopleVaccinated
		--(RollingPeopleVaccinated/population)*100
	from CovidProject.dbo.CovidDeaths$ d
		join
		CovidProject.dbo.CovidVaccinations$ v
		on d.date = v.date and d.location = v.location
	where d.continent is not null

select * from PercentPopulationVaccined
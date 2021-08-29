select *
from PortfolioProject..DeathsCovid
where continent is not null
order by  3,4


select *
from PortfolioProject..VacinationsCovid
order by  3,4


--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

select location, date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..DeathsCovid
where location like'Canada'
order by 1,2
 
 -- looking at total cases vs population
 -- Shows what percentage 
 select location, date,total_cases,population,(total_cases/population)*100 as PercentPopulationDeath
from PortfolioProject..DeathsCovid
where location like '%states%'
order by 1,2

--Looking at Countries with higher infection Rate compared to Population
--select location,population, MAX(total_cases) as HighestInfectionCountry ,MAX((total_cases/population))*100 as PercentPopulationInfected
--from PortfolioProject..CovidDeaths
----where location like '%states%'
--Group by location,population
--order by PercentPopulationInfected desc

---- showing countries with highest death count per population


select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..DeathsCovid
--where location like '%states%'
where continent is not null
Group by location
order by TotalDeathCount desc

-- let's break down by Continent
-- Showing the continent with the highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..DeathsCovid
--where location like '%states%'
where continent is not null
Group by continent
order by TotalDeathCount desc


--Global Numbers
select SUM(new_cases) as total_cases,sum(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..DeathsCovid
where continent is not null
--group by date
order by 1,2

-- Looking at Total Population vs Vaccinations


select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from PortfolioProject..DeathsCovid dea
join PortfolioProject..VaccinationsCovid vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
order by  2,3

-- USE CTE
With PopvsVac (Continent, Location, Date,Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from PortfolioProject..DeathsCovid dea
join PortfolioProject..VaccinationsCovid vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
--order by  2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
from PopvsVac

--Temp Table
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from PortfolioProject..DeathsCovid dea
join PortfolioProject..VaccinationsCovid vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
--order by  2,3

Select *,(RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--Creating View to store data for later visualization
Create View PercentPopulationVaccinated as
select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (Partition by dea.location order by dea.location, dea.date)as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Population)*100
from PortfolioProject..DeathsCovid dea
join PortfolioProject..VaccinationsCovid vac
     On dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
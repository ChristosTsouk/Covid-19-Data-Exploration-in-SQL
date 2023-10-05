SELECT * 
FROM PortfolioProject..CovidDeaths
Where continent is not null
Order By 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--Order By 3,4

Select location, date, total_cases, new_cases, total_deaths, Population
FROM PortfolioProject..CovidDeaths
Order By 1,2

--Total Cases vs Total Deaths
--Likelihood of dying if you contract Covid in a specific country

Select Location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like 'Cyprus'
order by 1,2

--Total Cases vs Population
--What percentage of population got Covid in  a specific country

Select Location, date, total_cases, Population, (NULLIF(CONVERT(float, total_cases), 0) / (population))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
Where location like 'Cyprus'
order by 1,2

--Looking at Countries with Highest Infection Rates compared to Population

Select Location, Population, MAX(CAST(total_cases as int)) as InfectionCount, MAX(NULLIF(CONVERT(float, total_cases), 0) / (population))*100 as InfectionPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Cyprus'
Where continent is not null
Group by Location, Population
order by InfectionPercentage desc

--Countries with Highest Death Count

Select Location, MAX(CAST(total_deaths as int)) as DeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Cyprus'
Where continent is not null
Group by Location
order by DeathCount desc

--Continent

Select continent, MAX(CAST(total_deaths as int)) as DeathCount
From PortfolioProject..CovidDeaths
--Where location like 'Cyprus'
Where continent is not null
Group by continent
order by DeathCount desc

--Global numbers

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like 'Cyprus'
where continent is not null
---Group by date
order by 1,2

--Total population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as PeopleVaccinatedCumulative
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--Use CTE

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, PeopleVaccinatedCumulative)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as PeopleVaccinatedCumulative
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (PeopleVaccinatedCumulative/population)*100
From PopVsVac 

--TEMP TABLE

DROP table if exists PercentPopulationVaccinated
Create table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinatedCumulative numeric
)
Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as PeopleVaccinatedCumulative
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3

Select *, (PeopleVaccinatedCumulative/population)*100
From PercentPopulationVaccinated

--Creating View to store data for visualizations


Create View PercentPopulationVaccinatedV as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as PeopleVaccinatedCumulative
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3



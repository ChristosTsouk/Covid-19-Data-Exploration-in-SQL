/*

Covid 19 Data Exploration

*/


--Looking at the columns of our tables

SELECT * 
FROM CovidProject..CovidDeaths
Where continent is not null
Order By 3,4

SELECT * 
FROM CovidProject..CovidVaccinations
Order By 3,4


-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, Population
FROM CovidProject..CovidDeaths
Where continent is not null
Order By 1,2


--Total Cases vs Total Deaths
--Likelihood of dying if you contract Covid in a specific country

Select Location, date, total_cases, total_deaths, CAST(total_deaths as float)/NULLIF(CAST(total_cases as float),0)*100 as DeathPercentage
From CovidProject..CovidDeaths
Where location like 'Cyprus'
and continent is not null
order by 1,2


--Total Cases vs Population
--What percentage of population got Covid in  a specific country

Select Location, date, Population, total_cases,  (total_cases/population)*100 as InfectionPercentage
From CovidProject..CovidDeaths
Where location like 'Cyprus'
order by 1,2


--Countries with Highest Infection Rate

Select Location, Population, MAX(CAST(total_cases as int)) as InfectionCount, MAX((total_cases) / (population))*100 as InfectionPercentage
From CovidProject..CovidDeaths
Where continent is not null
Group by Location, Population
order by InfectionPercentage desc


--Countries with Highest Death Count

Select Location, MAX(CAST(total_deaths as int)) as DeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by Location
order by DeathCount desc


--Continents with highest death count

Select continent, MAX(CAST(total_deaths as int)) as DeathCount
From CovidProject..CovidDeaths
Where continent is not null
Group by continent
order by DeathCount desc



--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage
From CovidProject..CovidDeaths
where continent is not null
order by 1,2


--Total population vs Vaccinations
--Percentage of pupulation that has received at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as PeopleVaccinatedCumulative
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3


--Using CTE to perform Calculation on Partition By in previous query

With PopVsVac (Continent, Location, Date, Population, new_vaccinations, PeopleVaccinatedCumulative)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as PeopleVaccinatedCumulative
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (PeopleVaccinatedCumulative/population)*100 as VaccinationPercentage
From PopVsVac 


--Using Temp Table to perform Calculation on Partition By in previous query

DROP table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
PeopleVaccinatedCumulative numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as PeopleVaccinatedCumulative
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (PeopleVaccinatedCumulative/population)*100 as VaccinationPercentage
From #PercentPopulationVaccinated


--Creating View to store data for visualizations

Create View PercentPopulationVaccinatedV as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date)
	as PeopleVaccinatedCumulative
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null











--COVID-19 DATA EXPLORATION FROM LATE 2020 TO EARLY 2021
--SKILLS USED: Aggregation Functions, CTEs, WINDOW FUNCTIONS, TEMP TABLES, DATA TYPES, JOINS, ARITHMETIC FUNCTIONS, VIEWS
--select*
--from ProjectPortfolio..CovidDeaths
--order by 3,4

--select*
--from ProjectPortfolio..CovidVaccinations
--order by 3,4

--Data to be used
Select Location, date,total_cases,new_cases, total_deaths,population
From ProjectPortfolio..CovidDeaths
order by 1,2

--Total Cases vs total deaths in SA from 07-02-2020 t0 30-04-2021
Select Location, date,total_cases, total_deaths,(total_deaths/total_cases)*100 AS percentage_deaths
From ProjectPortfolio..CovidDeaths
where location like 's%africa%' and continent is not null
order by 1,2

--Total cases vs Population
--Shows the population percentage that got covid
Select Location, date,total_cases, Population, (total_cases/Population)*100 AS percentage_Population
From ProjectPortfolio..CovidDeaths
where location like 's%africa%'
order by 1,2

--Countries with the highest infection rate compared to their population
Select Location, Population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/Population)*100 as percentage_Population
From ProjectPortfolio..CovidDeaths
group by location, population
order by percentage_Population desc

--Countries with the Highest Death Count per Population
Select Location, Population, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null
group by location, Population
order by TotalDeathCount desc

--CONTINENTS WITH THE HIGHEST DEATH COUNT PER POPULATION
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From ProjectPortfolio..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


----TO GET PRECISE NUMBERS/DATA THAT IS NOT INCLUDED WHEN GROUPED BY CONTINENT
--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From ProjectPortfolio..CovidDeaths
--where continent is null
--group by location
--order by TotalDeathCount desc

--Sum of new cases, sum of new deaths on a certain date and death percentage/ global numbers
Select date, sum(new_cases) as SumOfNewCases, sum(cast(new_deaths as int)) as SumOfNewDeaths, sum(cast(new_deaths as int))/sum(new_cases) as deathPercentage
From ProjectPortfolio..CovidDeaths
where continent is not null
group by date
order by 1,2


--TOTAL CASES
Select sum(new_cases) as SumOfNewCases, sum(cast(new_deaths as int)) as SumOfNewDeaths, sum(cast(new_deaths as int))/sum(new_cases) as deathPercentage
From ProjectPortfolio..CovidDeaths
where continent is not null
order by 1,2

----------JOINING THE TABLES COVIDDEATH AND COVIDVACCINATIONS

--JOINED TABLES
select*
from ProjectPortfolio..Coviddeaths as death
join ProjectPortfolio..CovidVaccinations as vac
on death.location = vac.location 
and death.date = vac.date

--Looking at total population vs vaccinations
select death.continent, death.location, death.date, death.population, vac.new_vaccinations
from ProjectPortfolio..Coviddeaths as death
join ProjectPortfolio..CovidVaccinations as vac
on death.location = vac.location 
and death.date = vac.date
where death.continent is not null
order by 2,3

--patition by the info at the top/ Looking at total population vs vaccinations
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location, death.date)  as SumOfVaccinated
from ProjectPortfolio..Coviddeaths as death
join ProjectPortfolio..CovidVaccinations as vac
on death.location = vac.location 
and death.date = vac.date
where death.continent is not null
order by 2,3

--USING CTEs
with PopuvsVacci (continent, location, date,population,new_vaccinations, SumOfVaccinated )
as (
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location, death.date)  as SumOfVaccinated
from ProjectPortfolio..Coviddeaths as death
join ProjectPortfolio..CovidVaccinations as vac
on death.location = vac.location 
and death.date = vac.date
where death.continent is not null
)
select*, (SumOfVaccinated/population)*100 as VaccinatedPercentage
from PopuvsVacci

----TEMP TABLE
DROP Table if exists #PercentOfPopulationVaccinated
create table #PercentOfPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
SumOfVaccinated numeric
)

insert into #PercentOfPopulationVaccinated
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location, death.date)  as SumOfVaccinated
from ProjectPortfolio..Coviddeaths as death
join ProjectPortfolio..CovidVaccinations as vac
on death.location = vac.location 
and death.date = vac.date
where death.continent is not null
order by 2,3

select*, (SumOfVaccinated/population)*100 as VaccinatedPercentage
from #PercentOfPopulationVaccinated

--Creating a view to store data for later visualization
create view PercentOfPopulationVaccinated as
select death.continent, death.location, death.date, death.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by death.location order by death.location, death.date)  as SumOfVaccinated
from ProjectPortfolio..Coviddeaths as death
join ProjectPortfolio..CovidVaccinations as vac
on death.location = vac.location 
and death.date = vac.date
where death.continent is not null

select *
from PercentOfPopulationVaccinated
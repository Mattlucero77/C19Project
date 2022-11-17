
--General Queries



--1.
--Select * 
--From CovidProject..CovidDeaths$
--Where continent is not null
--Order by 3,4


--ordering the project by both the date an location to see earliest covid deaths or vaccinations for the data we are using 


--2.
--Select * 
--From CovidProject..CovidVaccinations$
--Where continent is not null
--Order by 3,4 



--Selecting data that is needed from the covid deaths chart 


--3.
--Select location, date, total_cases, new_cases, total_deaths, population
--From CovidProject..
--Where continent is not null
--order by 1,2



--Death percent value found at end to see how likley an induvidual is to die if they contract covid in the United States


--4.
--Select location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 as DeathPercentage
--From CovidProject..CovidDeaths$
--Where continent is not null
--Where location like '%states%'
--order by 1,2



--Shows how much of the population has contracted covid out of a country's whole population


--5.
--Select location, date, total_cases, total_deaths, population, (total_cases/population) *100 as CovidPopulation
--From CovidProject..CovidDeaths$
--Where continent is not null
--Where location like '%states%'
--order by 1,2


--countries with highest infection rates compared to population


--6.
--Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) *100 as PercentPopulationInfected
--From CovidProject..CovidDeaths$
--Where continent is not null
--Where location like '%states%'--
--Group by Location, Population
--order by PercentPopulationInfected desc



--showing the countries with the highest death count per population


--7.
--Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
--From CovidProject..CovidDeaths$
--Where continent is not null
--Where location like '%states%'--
--Group by Location
--order by TotalDeathCount desc



-- highest death count BY CONTINENT 


--8.
--Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
--From CovidProject..CovidDeaths$
--Where continent is not null
--Where location like '%states%'--
--Group by continent
--order by TotalDeathCount desc







--Global Numbers:


--showing the new cases day by day as well as the percentage of deaths occuring on those days worldwide


--9.
--Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage

--From CovidProject..CovidDeaths$
--Where continent is not null
--Where location like '%states%'
--Group by date
--order by 1,2


--showing the total cases, total deaths, and what percentage of people have died


--10.
--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage

--From CovidProject..CovidDeaths$
--Where continent is not null
--Where location like '%states%'
--Group by date
--order by 1,2



--looking at total population vs vaccinations


--11.
--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalVaccinations

---From CovidProject..CovidDeaths$ dea
--Join CovidProject..CovidVaccinations$ vac
--on dea.location = vac.location
--and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3



-- USING CTE to allow calculations to be made on TotalVaccination Column to find total% of people vaccinated per country

--12.
--With PopvsVac (Continent, Location, Date, Population, new_vaccinations, TotalVaccinations)

--as
--
--(Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalVaccinations

--From CovidProject..CovidDeaths$ dea
--Join CovidProject..CovidVaccinations$ vac
--on dea.location = vac.location
--and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3)



--select*, (TotalVaccinations/Population)*100 as TotalPopVaccinated
--From PopvsVac



-- USING TEMP TABLE as an alt to CTEs to allow calculations to be made on TotalVaccination Column to find total% of people vaccinated per country

--13.

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
( 
continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric, 
new_vaccinations numeric, 
TotalVaccinations numeric)

insert  into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalVaccinations

From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


select*, (TotalVaccinations/Population)*100 as TotalPopVaccinated
From #PercentPopulationVaccinated





--Creating Views to store data for visualization

--Percent population vac view

--14.

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as TotalVaccinations

From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3


Select *
From PercentPopulationVaccinated




--table for total population deaths from query 9

--15.

Drop Table if exists #TotalDeathWorldPop
Create Table #TotalDeathWorldPop
(
date datetime, 
total_cases numeric, 
total_deaths numeric,
DeathPercentage numeric)

insert into #TotalDeathWorldPop
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage

From CovidProject..CovidDeaths$ 
Where continent is not null
--Where location like '%states%'
Group by date
--order by date



--view for total population deaths

--16.


Drop view if exists TotalDeathWorldPop


Use CovidProject
Go

Create view TotalDeathWorldPop 
as

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage

From CovidProject..CovidDeaths$ 
Where continent is not null
--Where location like '%states%'
Group by date
--order by date

select * 
From #TotalDeathWorldPop



--Table for total continent deaths 

--17.

Create Table #ContinentDeaths
(
continent nvarchar(255),
TotalDeathCount numeric)

Insert into #ContinentDeaths

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
Where continent is not null
Group by continent
--order by TotalDeathCount desc


--view creation for continent deaths

--18.

Use CovidProject

Go

Create View ContinentDeaths as
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
Where continent is not null
Group by continent
--order by TotalDeathCount desc






--Queries used for Tableau --




-- 1. (originally query 10)

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From CovidProject..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From CovidProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. (modified version of query 8)

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3. (modidied version of query 6)

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4. (modified version of query 6 with dates included to show the date of infections)


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidProject..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc
use project_covid

--Data used in this project comes from https://ourworldindata.org/covid-deaths

SELECT * FROM project_covid..CovidDeaths$
where continent is not null
order by location,date

SELECT * FROM project_covid..CovidVaccinations$
where continent is not null
order by location,date

--Showing data based on location

-- Select data that we are going to use
SELECT continent, location, date,total_cases, total_deaths, population  FROM CovidDeaths$
where continent is not null
order by 1,2

-- Total death vs total cases per location (country)
-- Here we can see death percentage in our country, example : indonesia
SELECT location, date, total_deaths, total_cases, (total_deaths/total_cases)*100 as death_percentage
FROM CovidDeaths$
where continent is not null
and total_deaths is not null
and location like '%indo%'
ORDER BY location,date

--Getting a percentage of population that got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as covid_percentage
FROM CovidDeaths$
where continent is not null
-- WHERE location like '%indo%'
order by 1,2

--Getting the infection_rate of based on latest total_cases and population
SELECT location, population, max(total_cases) as total_cases, max((total_cases/population))*100 as infection_rate
from CovidDeaths$
where continent is not null
group by location,population
order by 4 desc

--Showing country with infection rate higher that 15%
select * from
(
SELECT location, population, max(total_cases) as total_cases, max((total_cases/population))*100 as infection_rate
from CovidDeaths$
where continent is not null
group by location,population
)b
where b.infection_rate > 15
order by b.infection_rate asc


--Showing location with the percentage of death per population
SELECT location, population, max(total_deaths) as total_deaths, max((total_deaths/population))*100 as death_rate
from CovidDeaths$
where continent is not null
group by location, population
order by 4 desc

--Showing location with the death_rate lower than 0.1
SELECT * from 
(
SELECT location, population, max(total_deaths) as total_cases, max((total_deaths/population))*100 as death_rate
from CovidDeaths$
where continent is not null
group by location, population
)b
where b.death_rate < 0.1

--Death count per continent
SELECT continent, max(cast(total_deaths as int)) as Death_Count
from CovidDeaths$
where continent is not null
group by continent

--Total cases per country in 2020
select location, max(total_cases) as total_cases_in_2020
from CovidDeaths$
where year(date) = 2020
and continent is not null
group by location
order by 2

--continent with the most death
SELECT TOP 1 continent, max(cast(total_deaths as int)) as Death_Count
from CovidDeaths$
where continent is not null
group by continent
order by Death_Count desc

--new cases and deaths per day (global)
SELECT date, sum(new_cases) as cases_count, sum(cast(new_deaths as int)) as death_count,
(sum(cast(new_deaths as int))/sum(new_cases)) as death_rate
from CovidDeaths$
where continent is not null
group by date
order by date

--new death vs new vaccinations with the help of CTE
with DeavsVac(location, date, population, new_deaths, new_vaccinations, total_vaccinated)
as
(
select a.location, a.date, b.population, b.new_deaths, a.new_vaccinations,
SUM(cast(a.new_vaccinations as int)) OVER (PARTITION by a.location order by a.location, a.date) as total_vaccinated
from CovidVaccinations$ as a
join CovidDeaths$ as b
on a.location = b.location
and a.date = b.date
where a.new_vaccinations is not null
and a.new_vaccinations > 0
and a.continent is not null
--order by 2,1
)
SELECT *, (total_vaccinated/population) * 100 as vaccinated_percentage
from DeavsVac
order by 2, 1











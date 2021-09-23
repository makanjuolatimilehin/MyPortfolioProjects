--select all data from the covid death excel sheet
select *
from portfolioproject..coviddeaths$
Where continent is not null
order by continent, location

--select specific data from the covid death excel sheet
select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject..coviddeaths$
where continent is not null
order by location, date

--total deaths with respect to the amount of cases in percentage of people from nigeria
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as deaths_percentage
from portfolioproject..coviddeaths$
where location = 'nigeria'
and continent is not null
order by location, date

--total increase in covid recorded cases with respect to the population 
select location, date, population, total_cases, (total_cases/population) * 100 as cases_increase_in_percentage
from portfolioproject..coviddeaths$
where continent is not null
and continent is not null
order by location, date

--maximum cases with recorded for respective locations with respect to the population
select location, population, max(total_cases) as maximum_recorded_cases, max((total_cases/population)) * 100 as deaths_percentage_of_population
from portfolioproject..coviddeaths$
Where continent is not null
group by location, population
order by deaths_percentage_of_population desc

--total deaths recorded from respective location
select location,  max(cast(total_deaths as int)) as total_deaths_recorded
from portfolioproject..coviddeaths$
Where continent is not null
group by location
order by total_deaths_recorded desc

--total deaths recorded from respective continents
select continent,  max(cast(total_deaths as int)) as total_deaths_recorded
from portfolioproject..coviddeaths$
Where continent is not null
group by continent
order by total_deaths_recorded desc

--total cases and deaths recorded worldwide from covid inception till date
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases) * 100 as death_percenteage_of_the_world
from portfolioproject..coviddeaths$
where continent is not null
group by date
order by date

--daily count of people vaccinated worldwide
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
sum(convert(int, vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as sequential_people_vaccinated
from portfolioproject..coviddeaths$ death
join portfolioproject..covidvaccination$ vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
order by continent, location, date

--daily vaccination count in percent
with population_vaccination (continent, location, date, population, new_vaccinations, sequential_people_vaccinated)
as
(
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
sum(convert(int, vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as sequential_people_vaccinated
from portfolioproject..coviddeaths$ death
join portfolioproject..covidvaccination$ vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null
)
select *, (sequential_people_vaccinated/population) * 100 as vaccination_count_in_percent
from population_vaccination

create table #percentpopulationvaccinated
(
continent nvarchar(225),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
sequential_people_vaccinated  numeric
)

insert into #percentpopulationvaccinated
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
sum(convert(int, vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as sequential_people_vaccinated
from portfolioproject..coviddeaths$ death
join portfolioproject..covidvaccination$ vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null

select *, (sequential_people_vaccinated/population) * 100
from  #percentpopulationvaccinated

create view percentpopulationvaccinated as 
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations,
sum(convert(int, vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as sequential_people_vaccinated
from portfolioproject..coviddeaths$ death
join portfolioproject..covidvaccination$ vaccine
on death.location = vaccine.location
and death.date = vaccine.date
where death.continent is not null







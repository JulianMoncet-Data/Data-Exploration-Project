-- Table development and data upload --

CREATE TABLE IF NOT EXISTS Coviddeaths (
    iso_code VARCHAR (255),
    continent VARCHAR(255),
    location VARCHAR (255),
    date_ DATE,
    population VARCHAR (255),
    total_cases VARCHAR (255),
    new_cases VARCHAR (255),
    new_cases_smoothed VARCHAR (255),
    total_deaths VARCHAR (255),
    new_deaths VARCHAR (255),
    new_deaths_smoothed VARCHAR (255),
    total_cases_per_million VARCHAR (255),
    new_cases_per_million VARCHAR (255),
    new_cases_smoothed_per_million VARCHAR (255),
    total_deaths_per_million VARCHAR (255),
    new_deaths_per_million VARCHAR (255),
    new_deaths_smoothed_per_million VARCHAR (255),
    reproduction_rate VARCHAR (255),
    icu_patients VARCHAR (255),
    icu_patients_per_million VARCHAR (255),
    hosp_patients VARCHAR (255),
    hosp_patients_per_million VARCHAR (255),
    weekly_icu_admissions VARCHAR (255),
    weekly_icu_admissions_per_million VARCHAR (255),
    weekly_hosp_admissions VARCHAR (255),
    weekly_hosp_admissions_per_million VARCHAR (255)
    );
    
select * from coviddeaths;
ALTER TABLE coviddeaths RENAME COLUMN date_ TO date_date;
SET @@GLOBAL.local_infile = 1;
SHOW VARIABLES LIKE "secure_file_priv"; 
ALTER TABLE coviddeaths    
MODIFY iso_code text;
SET SQL_SAFE_UPDATES = 1;

DELETE FROM coviddeaths;

CREATE TABLE IF NOT EXISTS Covidvaccines (
    iso_code TEXT,
    continent VARCHAR(255),
    location VARCHAR (255),
    date_date DATE,
    new_tests VARCHAR (255),
    total_tests VARCHAR (255),
    total_tests_per_thousand VARCHAR (255),
    new_tests_per_thousand VARCHAR (255),
    new_tests_smoothed VARCHAR (255),
    new_tests_smoothed_per_thousand VARCHAR (255),
    positive_rate VARCHAR (255),
    tests_per_case VARCHAR (255),
    tests_units VARCHAR (255),
    total_vaccinations VARCHAR (255),
    people_vaccinated VARCHAR (255),
    people_fully_vaccinated VARCHAR (255),
    new_vaccinations VARCHAR (255),
    new_vaccinations_smoothed VARCHAR (255),
    total_vaccinations_per_hundred VARCHAR (255),
    people_vaccinated_per_hundred VARCHAR (255),
    people_fully_vaccinated_per_hundred VARCHAR (255),
    new_vaccinations_smoothed_per_million VARCHAR (255),
    stringency_index VARCHAR (255),
    population_density VARCHAR (255),
    median_age VARCHAR (255),
    aged_65_older VARCHAR (255),
    aged_70_older VARCHAR (255),
    gdp_per_capita VARCHAR (255),
    extreme_poverty VARCHAR (255),
    cardiovasc_death_rate VARCHAR (255),
    diabetes_prevalence VARCHAR (255),
    female_smokers VARCHAR (255),
    male_smokers VARCHAR (255),
    handwashing_facilities VARCHAR (255),
    hospital_beds_per_thousand VARCHAR (255),
    life_expectancy VARCHAR (255),
    human_development_index VARCHAR (255)
    );
    
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Covid_vaccinations.csv' 
INTO TABLE covidvaccines 
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


select * from covidvaccines;
DELETE FROM covidvaccines;
SET SQL_SAFE_UPDATES = 1;

-- End of Data Upload and Quering data issues --

Select Location, date_date, total_cases, new_cases, total_deaths, population
from coviddeaths
where continent is not null
order by 1, 2;

-- Looking at Total cases vs Total Deaths --
-- Shows Likelihood of dying if you contracted Covid-19 in your country--
Select Location, date_date, total_cases, total_deaths, (total_deaths / total_cases)* 100 as DeathPorcentage
from coviddeaths
where location like "argentina"
and continent is not null
order by 1, 2;

-- Looking at total cases vs population --
-- Shows what % of population got Covid-19--

Select Location, date_date, population, total_cases, (total_cases / population)* 100 as PercentPopulationInfected
from coviddeaths
where location like "argentina"
and continent is not null
order by 1, 2;

-- Looking at countries with HIGHEST infection rate compared to population --

Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases / population))* 100 as PercentPopulationInfected
from coviddeaths
where continent is not null
group by Location, population
 -- where location like "argenitna" --
order by PercentPopulationInfected desc;
 
-- Showing countries with the HIGHEST Death Count per Population --

Select Location, SUM(cast(total_deaths as signed)) as TotalDeathCount
from coviddeaths
where continent is not null
group by Location
order by TotalDeathCount desc;

-- Now by Continet --

Select continent, MAX(cast(total_deaths as SIGNED)) as TotalDeathCount
from coviddeaths
where continent is not null
group by continent
order by TotalDeathCount desc;

-- Showing contintents with the highest death count per population --

Select continent, MAX(cast(Total_deaths as signed)) as TotalDeathCount
From CovidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc;

-- Global Numbers Total --

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths
where continent is not null 
-- Group By date --
order by 1,2 ;

-- Global Numbers by date --

Select date_date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as signed)) as total_deaths, SUM(cast(new_deaths as signed))/SUM(New_Cases)*100 as DeathPercentage
From coviddeaths
where continent is not null 
Group By date_date
order by 1,2 ;

-- Total Population vs Vaccinations --
-- Shows Percentage of Population that has recieved at least one Covid Vaccine --

select * from coviddeaths;

Select dea.continent, dea.location, dea.date_date, dea.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.date_date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100 --
From coviddeaths dea
Join covidVaccines vacc
	On dea.location = vacc.location
	and dea.date_date = vacc.date_date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query (conditions) (Depending on Mysql version it may or may not work the "With" statement --

With PopvsVac (Continent, Location, date_date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date_date, dea.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.date_date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100 --
From coviddeaths dea
Join covidVaccines vacc
	On dea.location = vacc.location
	and dea.date_date = vacc.date_date
where dea.continent is not null 
order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query --
DROP Table if exists PercentPopulationVaccinated

Create Table PercentPopulationVaccinated
(
Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date_date, dea.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.date_date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100 --
From coviddeaths dea
Join covidVaccines vacc
	On dea.location = vacc.location
	and dea.date_date = vacc.date_date
where dea.continent is not null 
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated

-- View creation to store data for later visualizations (Power BI, Tableau) (Remember to DROP PercentagePopulatonVaccinated Table) --

Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date_date, dea.population, vacc.new_vaccinations
, SUM(CAST(vacc.new_vaccinations as signed)) OVER (Partition by dea.Location Order by dea.location, dea.date_date) as RollingPeopleVaccinated
-- , (RollingPeopleVaccinated/population)*100 --
From coviddeaths dea
Join covidVaccines vacc
	On dea.location = vacc.location
	and dea.date_date = vacc.date_date
where dea.continent is not null 
-- order by 2,3 (can´t developr views using order by statement) --

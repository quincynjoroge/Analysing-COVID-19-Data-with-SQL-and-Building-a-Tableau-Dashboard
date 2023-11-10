	-- Checking all the data has been loaded from both tables
SELECT *
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL;

SELECT *
FROM Covid19..covidvaccinations$;

-- Selecting the columns we will be using for analysis
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Covid19..coviddeaths$
ORDER BY 1;

-- Let's explore total deaths vs total cases
-- % of people who had covid that died...shows likekihood of an indivisual dying having contracted Covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS deathpercentage
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL AND location like '%kingdom%'  -- we will check the united Kingdom for exploration purposes
ORDER BY 1,2;

-- Lets look at what % of the population have been infected with covid
--Total cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infected_pop_percentage
FROM Covid19..coviddeaths$
WHERE location like '%kingdom%' AND continent IS NOT NULL 
ORDER BY 2;
-- calculating the global infection rate to avoid double-counting the population for duplicate locations, 
-- we will use a subquery with a window function(CTE) to assign row numbers to each location and then 
-- order the rows in descending order by date and then select rows with RowNum = 1 to get the most recent date and cases
WITH RankedData AS (
    SELECT
        location,
        date,
        total_cases,
        population,
        ROW_NUMBER() OVER (PARTITION BY location ORDER BY date DESC) AS RowNum
    FROM
        Covid19..coviddeaths$
    WHERE
        continent IS NOT NULL
)
SELECT
    SUM(total_cases) OVER (ORDER BY date) AS global_total_cases,
    SUM(population) OVER (ORDER BY date) AS global_population,
    (SUM(total_cases) OVER (ORDER BY date) / SUM(population) OVER (ORDER BY date)) * 100 AS global_infected_pop_percentage
FROM RankedData
WHERE
  RowNum = 1;

  -- death rate
  WITH RankedDeathData AS (
    SELECT
        location,
        date,
        total_deaths,
        population,
        ROW_NUMBER() OVER (PARTITION BY location ORDER BY date DESC) AS RowNum
    FROM
        Covid19..coviddeaths$
    WHERE
        continent IS NOT NULL
)
SELECT
    SUM(total_deaths) OVER (ORDER BY date) AS global_total_cases,
    SUM(population) OVER (ORDER BY date) AS global_population,
    (SUM(total_deaths) OVER (ORDER BY date) / SUM(population) OVER (ORDER BY date)) * 100 AS global_death_pop_percentage
FROM RankedDeathData
WHERE
  RowNum = 1;


-- Lets look at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highestinfectioncount, MAX((total_cases/population))*100 AS infected_pop_percentage
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL 
GROUP BY location,population
ORDER BY infected_pop_percentage DESC;

-- Let's see the countries with highest death counts 
SELECT location, MAX(total_deaths) AS deathcount
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY deathcount DESC;
-- The United States has the highest death count with 1,127,152 deaths, followed by Brazil(704,659) and India(532,030)

-- Lets explore deathcount by continent
SELECT continent, MAX(total_deaths) AS deathcount
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL 
GROUP BY continent
ORDER BY deathcount DESC; 
-- North America has the highest death count with 1,127,152 deaths, 
-- followed by South America(704,659), Asia(532,030),Europe(400,023),Africa(102,595),Oceania(22,887)

-- GLOBAL NUMBERS
--Daily COVID-19 fatality rate among those who have contracted the virus
SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS deathpercentage
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL 
GROUP BY date
ORDER BY 1,2;

-- Overall global COVID-19 fatality rate among those who have contracted the virus
SELECT SUM(new_cases) AS total_cases, 
       SUM(new_deaths) AS total_deaths, 
	   (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS deathpercentage
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL 
ORDER BY 1,2;

-- Joining the vaccination table and the deaths table using INNER JOIN on location and date
--Let's examine the total population in comparison to the vaccination rate
SELECT d.continent, d.location, d.date, population, v.new_vaccinations, 
SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS rolling_count_people_vaccinated
FROM Covid19..coviddeaths$ d
JOIN Covid19..covidvaccinations$ v
     ON d.location = v.location
	 AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3;

-- % of population vaccinated in each location
-- using a CTE
WITH vaccination_rate (continent, location, date, population,new_vaccinations,rolling_count_people_vaccinated)
AS (
SELECT d.continent, d.location, d.date, population, v.new_vaccinations, 
SUM(CONVERT(int,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS rolling_count_people_vaccinated
FROM Covid19..coviddeaths$ d
JOIN Covid19..covidvaccinations$ v
     ON d.location = v.location
	 AND d.date = v.date
WHERE d.continent IS NOT NULL)
SELECT *,(rolling_count_people_vaccinated/population)*100 AS percent_population_vaccinated
FROM vaccination_rate;

-- using a TEMP table for same query above
DROP TABLE if exists #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric,
new_vaccinations numeric,
rolling_count_people_vaccinated numeric)

insert into #percentpopulationvaccinated
SELECT d.continent, d.location, d.date, population, v.new_vaccinations, 
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS rolling_count_people_vaccinated
FROM Covid19..coviddeaths$ d
JOIN Covid19..covidvaccinations$ v
     ON d.location = v.location
	 AND d.date = v.date
WHERE d.continent IS NOT NULL

SELECT *,(rolling_count_people_vaccinated/population)*100 AS percent_population_vaccinated
FROM #percentpopulationvaccinated
ORDER BY 2,3;

-- Calculating vaccination rate overall
SELECT SUM(CAST(new_vaccinations AS float)) / SUM(population)* 100 AS vaccination_percentage
FROM Covid19..coviddeaths$ d
JOIN Covid19..covidvaccinations$ v
     ON d.location = v.location
	 AND d.date = v.date
WHERE d.continent IS NOT NULL;


-- Creating a view to organize and save data for future use(data visualization purposes)
CREATE VIEW percentpopulationvaccinated AS
SELECT d.continent, d.location, d.date, population, v.new_vaccinations, 
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS rolling_count_people_vaccinated
FROM Covid19..coviddeaths$ d
JOIN Covid19..covidvaccinations$ v
     ON d.location = v.location
	 AND d.date = v.date
WHERE d.continent IS NOT NULL;
--------------------------------------------------------------------------------------------------------------------------------------
--- Dashboard Analysis 
-- Displaying the necessary columns we need for analysis form the Covid Deaths Table
SELECT iso_code, 
      continent, 
	  location, 
	  CAST(date AS DATE) AS date, 
	  population, 
	  total_cases, 
	  new_cases, 
	  total_deaths, 
	  new_deaths, 
	  icu_patients, 
	  hosp_patients, 
	  total_tests
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL;

-- Let us check the ditinct continents
SELECT DISTINCT continent
FROM Covid19..coviddeaths$;
-- We have a null continent and we are missing the Eurobe continent. 
-- Let's check if the Null contnent is for Europe countries
SELECT continent, location
FROM Covid19..coviddeaths$
WHERE continent IS NULL;
-- So from the table the rows where continent is NULL, the conitnent name is defined in the location column
--  We will have to exclude the NULL rows during analysis.

-- Checking the total number of confirmed cases globally
SELECT CAST(date AS DATE) AS date, SUM(new_cases) AS confimed_cases
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;
-- Checking the total number of confirmed cases globally by continent
SELECT continent, SUM(new_cases) AS confimed_cases
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY confimed_cases DESC;
-- Confirmed Cases by country
SELECT date, location, new_cases
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL
ORDER BY date, location;
-- Checking the total number of confirmed deaths globally
SELECT CAST(date AS DATE) AS date, SUM(new_deaths) AS confimed_deaths
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;
-- Checking the total number of confirmed deaths globally by continent
SELECT continent, SUM(new_deaths) AS confimed_deaths
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY confimed_deaths DESC;
-- Confirmed deaths by country
SELECT date, location, new_deaths
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL
ORDER BY date, location;

-- Analysing Death rate and Infection rate 
SELECT location, MAX(total_cases)/population*100 AS infection_rate, MAX(total_deaths)/population*100 AS death_rate
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL
GROUP BY location,population;

-- Analysing number of tests 
SELECT date, MAX(total_tests) AS total_tests
FROM Covid19..coviddeaths$
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;

-- Displaying the necessary columns we need for analysis form the Covid Vaccinations Table
SELECT v.iso_code, 
      v.continent, 
	  v.location, 
	  d.population,
	  CAST(v.date AS DATE) AS date, 
	  total_vaccinations, 
	  people_vaccinated, 
	  people_fully_vaccinated, 
	  total_boosters, 
	  new_vaccinations
FROM Covid19..covidvaccinations$ v
JOIN Covid19..coviddeaths$ d
     ON d.location = v.location
	 AND d.date = v.date
WHERE v.continent IS NOT NULL;

-- vaccination rate
WITH RankedVaccineData AS (
    SELECT
        v.location,
        v.date,
        total_vaccinations,
        population,
        ROW_NUMBER() OVER (PARTITION BY v.location ORDER BY v.date DESC) AS RowNum
    FROM
        Covid19..covidvaccinations$ v
	JOIN Covid19..coviddeaths$ d
	   ON d.location = v.location
	   AND d.date = v.date
    WHERE
        v.continent IS NOT NULL
)
SELECT
    SUM(total_vaccinations) OVER (ORDER BY date) AS global_total_vaccinations,
    SUM(population) OVER (ORDER BY date) AS global_population,
    (SUM(total_vaccinations) OVER (ORDER BY date) / SUM(population) OVER (ORDER BY date)) * 100 AS global_vaccine_pop_percentage
FROM RankedVaccineData
WHERE
  RowNum = 1;
  ----


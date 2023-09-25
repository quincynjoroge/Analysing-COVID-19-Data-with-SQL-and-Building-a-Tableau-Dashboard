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
ORDER BY 2;

-- Lets look at what % of the population have been infected with covid
--Total cases vs Population
SELECT location, date, population, total_cases, (total_cases/population)*100 AS infected_pop_percentage
FROM Covid19..coviddeaths$
WHERE location like '%kingdom%' AND continent IS NOT NULL 
ORDER BY 2;

-- Lets look at countries with highest infection rate compared to popularion
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
SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, (SUM(new_deaths)/NULLIF(SUM(new_cases),0))*100 AS deathpercentage
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

-- Creating a view to organize and save data for future use(data visualization purposes)
CREATE VIEW percentpopulationvaccinated AS
SELECT d.continent, d.location, d.date, population, v.new_vaccinations, 
SUM(CONVERT(bigint,v.new_vaccinations)) OVER (PARTITION BY d.location ORDER BY d.location,d.date) AS rolling_count_people_vaccinated
FROM Covid19..coviddeaths$ d
JOIN Covid19..covidvaccinations$ v
     ON d.location = v.location
	 AND d.date = v.date
WHERE d.continent IS NOT NULL;

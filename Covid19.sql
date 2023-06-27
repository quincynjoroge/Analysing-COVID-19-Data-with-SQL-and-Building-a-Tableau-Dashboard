USE covid;
-- Total COVID-19 Cases by Country: 
-- Retrieve the total number of confirmed cases for each country, ordered in descending order.
SELECT location, SUM(total_cases) AS confirmed_cases
FROM cases_deaths
WHERE location NOT LIKE '%income' AND location != 'World'
GROUP BY location
ORDER BY  confirmed_cases DESC;

-- Daily New Deaths: Calculate the number of new deaths reported each day, along with the corresponding date
SELECT date, SUM(new_deaths) AS number_of_deaths
FROM cases_deaths
GROUP BY date
ORDER BY STR_TO_DATE(date, '%m/%d/%Y');

-- Retrieve the total number of vaccinations administered in each country.
SELECT location, SUM(total_vaccinations) AS total_administered_vaccinations
FROM vaccinations
WHERE location NOT LIKE '%income' AND location != 'World' AND location NOT IN('Asia', 'Africa', 'North America', 'South America', 'Antarctica', 'Europe', 'Australia','European Union')
GROUP BY location
ORDER BY total_administered_vaccinations DESC;

-- Find the country/countries with the highest number of people fully vaccinated 
SELECT v.location, v.iso_code, v.people_fully_vaccinated
FROM vaccinations v
WHERE v.people_fully_vaccinated = (
    SELECT MAX(people_fully_vaccinated)
    FROM vaccinations
);

-- Retrieve the total cases and total deaths attributed to COVID-19
SELECT location, SUM(total_cases) AS total_cases, SUM(total_deaths) AS total_deaths
FROM cases_deaths 
WHERE location NOT LIKE '%income' AND location != 'World' AND location NOT IN('Asia', 'Africa', 'North America', 'South America', 'Antarctica', 'Europe', 'Australia','European Union')
GROUP BY location;

-- Retrieve the top 5 countries with the highest average daily ICU occupancy per million people
SELECT * FROM hospitalizations;
WITH cte AS (
    SELECT h.entity AS country, AVG(h.value) AS avg_daily_icu_occupancy_per_million
    FROM hospitalizations h
    WHERE h.indicator = 'Daily ICU occupancy per million'
    GROUP BY h.entity
)
SELECT cte.country, cte.avg_daily_icu_occupancy_per_million
FROM cte
ORDER BY cte.avg_daily_icu_occupancy_per_million DESC
LIMIT 5;

-- Calculate the average daily vaccinations per million people for each country
WITH cte AS (
    SELECT v.location, v.total_vaccinations, p.2023_last_updated AS population
    FROM vaccinations v
    JOIN 2023_population p ON v.location = p.country
)
SELECT cte.location, (cte.total_vaccinations / (cte.population / 1000000)) AS avg_daily_vaccinations_per_million
FROM cte;

-- Total Cases vs Total Deaths
-- Calculating the probability of mortality upon contracting COVID-19 in your country.
SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM cases_deaths
WHERE location NOT LIKE '%income' AND location != 'World' AND location NOT IN('Asia', 'Africa', 'North America', 'South America', 'Antarctica', 'Europe', 'Australia','European Union')
order by location, date;

-- Calculate the total number of deaths and total cases for each country, and derive the percentage representing the likelihood of death. 
-- This information provides insights into the severity of COVID-19 impact in different countries.

SELECT location,SUM(total_cases) as total_cases,SUM(total_deaths) as total_deaths, ROUND((SUM(total_deaths)/SUM(total_cases))*100,2) as DeathPercentage
FROM cases_deaths
WHERE location NOT LIKE '%income' AND location != 'World' AND location NOT IN('Asia', 'Africa', 'North America', 'South America', 'Antarctica', 'Europe', 'Australia','European Union')
GROUP BY location
order by location;

-- Countries with Highest Infection Rate compared to Population
WITH total_cases AS (
    SELECT
        location,
        MAX(total_cases) AS highest_infection_count
    FROM
        cases_deaths
    WHERE
        location NOT LIKE '%income'
        AND location != 'World'
        AND location NOT IN ('Asia', 'Africa', 'North America', 'South America', 'Antarctica', 'Europe', 'Australia', 'European Union')
    GROUP BY
        location
),
total_population AS (
    SELECT
        country,
        CAST(REPLACE(2023_last_updated, ',', '') AS DECIMAL) AS population
    FROM
        2023_population
       
)
SELECT
    tc.location,
    tp.population,
    tc.highest_infection_count,
    ROUND((tc.highest_infection_count / tp.population) * 100, 2) AS percent_population_infected
FROM
    total_cases tc
JOIN
    total_population tp ON tc.location = tp.country
ORDER BY
    percent_population_infected DESC;

-- -- Countries with Highest Death Count 
SELECT location, SUM(total_deaths) AS TotalDeathCount
FROM cases_deaths
WHERE
        location NOT LIKE '%income'
        AND location != 'World'
        AND location NOT IN ('Asia', 'Africa', 'North America', 'South America', 'Antarctica', 'Europe', 'Australia', 'European Union')
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- -- Showing contintents with the highest death count per population  
SELECT location, SUM(total_deaths) AS DeathCount
FROM cases_deaths 
WHERE location IN ('Asia', 'Africa', 'North America', 'South America', 'Antarctica', 'Europe', 'Australia')
GROUP BY location
ORDER BY DeathCount DESC;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
WITH vaccination_summary AS (
    SELECT
        c.location,
        c.date,
        p.2023_last_updated,
        v.people_vaccinated,
        SUM(v.people_vaccinated) OVER (PARTITION BY c.location ORDER BY c.date) AS RollingPeopleVaccinated
    FROM
        cases_deaths c
    JOIN
        vaccinations v ON c.location = v.location AND c.date = v.date
    JOIN
        2023_population p ON c.location = p.country
    WHERE
        c.location NOT LIKE '%income'
        AND c.location != 'World'
        AND c.location NOT IN ('Asia', 'Africa', 'North America', 'South America', 'Antarctica', 'Europe', 'Australia', 'European Union')
)
SELECT
    location,
    date,
    2023_last_updated,
    people_vaccinated,
    (RollingPeopleVaccinated / 2023_last_updated) * 100 AS PercentageVaccinated
FROM vaccination_summary
ORDER BY location, date;

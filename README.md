# Covid19-Analysis

## Introduction
The COVID-19 Data Analysis project aims to analyze and derive insights from COVID-19 data using SQL. The data for this analysis was sourced from the Our World in Data GitHub page, which collects data from the World Health Organization (WHO). The project focuses on various aspects of the pandemic, including total confirmed cases, daily new deaths, vaccination administration, ICU occupancy, mortality rates, infection rates, and more.

To conduct the analysis, SQL queries were implemented using the MySQL Workbench tool. The project leverages the power of SQL to manipulate and aggregate the COVID-19 data, enabling meaningful insights to be derived. Each SQL query addresses a specific question or objective and provides valuable information about the global impact of COVID-19.

The project encompasses multiple analyses, including:

**Total COVID-19 Cases by Country**: This analysis retrieves the total number of confirmed cases for each country, allowing for a comparative overview of the global situation.

**Daily New Deaths**: By calculating the number of new deaths reported each day, this analysis provides insights into the progression of COVID-19 fatalities over time.

**Vaccination Administration**: The total number of vaccinations administered in each country is examined to gauge the scale of vaccination efforts worldwide.

**Fully Vaccinated Individuals**: The countries with the highest number of people fully vaccinated are identified to highlight successful vaccination campaigns.

**Total Cases and Deaths**: This analysis retrieves the total number of cases and deaths attributed to COVID-19 for each country, providing a comprehensive view of the pandemic's impact.

**Average Daily ICU Occupancy**: By analyzing ICU occupancy per million people, this analysis identifies the top five countries with the highest average daily ICU occupancy rates, shedding light on healthcare system strain.

**Average Daily Vaccinations**: The average daily vaccinations per million people are calculated for each country, showcasing the vaccination rates and progress in different regions.

**Total Cases vs Total Deaths**: This analysis explores the relationship between total cases and total deaths, allowing for the calculation of the probability of mortality upon contracting COVID-19 in various countries.

**Countries with the Highest Infection Rate compared to Population**: By comparing the highest infection counts to population size, this analysis highlights countries with the highest infection rates in relation to their population.

**Countries with the Highest Death Count**: This analysis identifies the countries with the highest death counts attributed to COVID-19, indicating the severity of the pandemic's impact.

**Continents with the Highest Death Count per Population**: By analyzing death counts per population, this analysis reveals the continents most affected by COVID-19.

**Total Population vs. Vaccinations**: This analysis examines the percentage of the population that has received at least one COVID-19 vaccine dose, providing insights into the progress of vaccination efforts globally.

Through these analyses, the project aims to contribute to a better understanding of the COVID-19 pandemic, its impact on different regions, and the effectiveness of vaccination campaigns.
## Data Sources:

The data for this project was sourced from the Our World in Data GitHub page, which obtains its data from the World Health Organization (WHO). The COVID-19 dataset used includes information on confirmed cases and deaths. Additionally, population data was acquired from Kaggle to provide context for the analysis.

Please note that the specific links to the datasets can be found below:
[Kaggle population datsset](https://www.kaggle.com/datasets/rsrishav/world-population?resource=download&select=2023_population.csv)
[Covid dataset](https://github.com/owid/covid-19-data/tree/master/public/data)

## Project Setup:

To set up and replicate the COVID-19 data analysis project, follow these steps:

### Tools and Technologies:

**SQL**: Structured Query Language (SQL) is the primary tool used for data analysis in this project.

**MySQL Workbench**: MySQL Workbench is the chosen interface to interact with the MySQL database management system (DBMS) for executing SQL queries and managing the database.
Database Setup:

**Install MySQL**: Start by installing the MySQL DBMS on your machine. You can download the appropriate version for your operating system from the official MySQL website.

**Create a Database**: Once MySQL is installed, open MySQL Workbench and connect to the MySQL server. Create a new database using a suitable name for your project.

**Data Import**:
**Download the Data**: Download the COVID-19 dataset files from the Our World in Data GitHub page. Additionally, acquire the population dataset from Kaggle.

**Import Data into Tables**: Use the MySQL Workbench to import the downloaded datasets into their respective tables in the database. Ensure that the table structure matches the data columns.

**SQL Queries**:

**Accessing the Database**: Open MySQL Workbench and connect to the MySQL server. Select the database you created for this project.

**SQL Queries**: Utilize the SQL queries provided in the project repository to perform various analyses on the COVID-19 data. These queries are documented in the repository's documentation.

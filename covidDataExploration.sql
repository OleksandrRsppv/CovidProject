USE Covid;
SELECT * FROM coviddeath 
WHERE continent IS NOT NULL
ORDER BY 3,4;

SELECT * FROM covidvactinations 
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeath;

-- Looking total cases VS total deaths

-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage
FROM coviddeath
WHERE location LIKE "%poland%";

-- Looking total cases VS population
-- Shows what percentage of population got Covid
SELECT location, date, total_cases, new_cases, population, (total_cases / population) AS cases_percentage
FROM coviddeath
WHERE location LIKE "%poland%";

-- Loking at the country with Highest Infection Rate compared to population
SELECT location, population, MAX(total_cases) AS highest_infection_rate,
MAX((total_cases / population)) * 100 AS percent_population_infected
FROM coviddeath
GROUP BY location, population
ORDER BY percent_population_infected DESC;

-- Loking at the country with Highest Infection Rate compared to population with date
SELECT location, population, date, MAX(total_cases) AS highest_infection_rate,
MAX((total_cases / population)) * 100 AS percent_population_infected
FROM coviddeath
GROUP BY location, population, date
ORDER BY percent_population_infected DESC;


-- Showing the countries with Highest Death Count per population

SELECT location, population, MAX(CAST(total_deaths as UNSIGNED)) AS highest_death_count
FROM coviddeath
-- Deleting incorrect location
WHERE location NOT IN 
("World", "High income", "Upper middle income", 
"Europe", "North America", "Asia", 
"Lower middle income", "South America", "European Union")
-- Deleting incorrect location
GROUP BY location, population
ORDER BY highest_death_count DESC;

-- Breaking things down by continent

SELECT location, MAX(CAST(total_deaths as UNSIGNED)) AS total_death_count
FROM coviddeath 
WHERE location = "Europe" 
OR location = "North America" 
OR location = "Asia"
OR location = "South America"
OR location = "Africa"
OR location = "Oceania"
GROUP BY location
ORDER BY total_death_count DESC;

-- Continents with the highest death count per population

SELECT continent, MAX(CAST(total_deaths AS UNSIGNED)) AS deaths_by_continets
FROM coviddeath
GROUP BY continent
ORDER BY deaths_by_continets DESC;

-- Global numbers

-- Death percentage across the world by days
SELECT date, SUM(new_cases) AS sum_of_new_cases, SUM(CAST(new_deaths AS UNSIGNED)) sum_of_new_deaths,
 SUM(CAST(new_deaths AS UNSIGNED)) / SUM(new_cases) * 100 AS death_percentage
FROM coviddeath
-- Deleting incorrect location
WHERE location NOT IN 
("World", "High income", "Upper middle income", 
"Europe", "North America", "Asia", 
"Lower middle income", "South America", "European Union")
-- Deleting incorrect location
GROUP BY date
ORDER BY death_percentage DESC;

-- total
SELECT SUM(new_cases) AS sum_of_cases, SUM(CAST(new_deaths AS UNSIGNED)) sum_of_deaths,
 SUM(CAST(new_deaths AS UNSIGNED)) / SUM(new_cases) * 100 AS death_percentage
FROM coviddeath
-- Deleting incorrect location
WHERE location NOT IN 
("World", "High income", "Upper middle income", 
"Europe", "North America", "Asia", 
"Lower middle income", "South America", "European Union")
-- Deleting incorrect location
ORDER BY death_percentage DESC;

-- Looking for a total vactination VS population

SELECT dea.continent, dea.location, dea.date, dea.population, new_vaccinations, 
SUM(CAST(new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVactinated
FROM coviddeath dea

JOIN covidvactinations vact
ON dea.location = vact.location
AND dea.date = vact.date 
-- Deleting incorrect location
WHERE location NOT IN 
("World", "High income", "Upper middle income", 
"Europe", "North America", "Asia", 
"Lower middle income", "South America", "European Union");
-- Deleting incorrect location

-- USE CTE

WITH PopVsVact  (continent, location, date, population, new_vaccinations, rollingPeopleVactinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vact.new_vaccinations, 
SUM(CAST(new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVactinated
FROM coviddeath dea

JOIN covidvactinations vact
ON dea.location = vact.location
AND dea.date = vact.date 
-- Deleting incorrect location
WHERE location NOT IN 
("World", "High income", "Upper middle income", 
"Europe", "North America", "Asia", 
"Lower middle income", "South America", "European Union")
)
-- Deleting incorrect location
SELECT *, (rollingPeopleVactinated/population) * 100
FROM PopVsVact;

DROP TABLE IF EXISTS PercentPopulationVacinated;

-- Creating view to store data later visualization

DROP TABLE IF EXISTS PercentPopulationVacinated;

CREATE VIEW PercentPopulationVacinated AS
SELECT dea.continent, dea.location, dea.date,dea.population, vact.new_vaccinations, 
SUM(CAST(new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingPeopleVactinated
FROM coviddeath dea
JOIN covidvactinations vact
ON dea.location = vact.location
AND dea.date = vact.date 
-- Deleting incorrect location
WHERE location NOT IN 
("World", "High income", "Upper middle income", 
"Europe", "North America", "Asia", 
"Lower middle income", "South America", "European Union"); 

SELECT *
FROM PercentPopulationVacinated
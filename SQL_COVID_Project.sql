SELECT *
FROM coviddeaths
ORDER BY 3,4;

SELECT *
FROM covidvaccinations
ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths
ORDER BY 3,4;

-- Total Cases VS Total Deaths
-- Shows likelihood of dying of Covid in United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as death_percentage
FROM CovidDeaths
WHERE location like '%States%'
ORDER BY 1,2;

-- Total Cases VS Population
-- Shows percentage of population that got Covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 as positive_percentage
FROM CovidDeaths
WHERE location like '%States%'
ORDER BY 1,2;

-- Looking at countries with highest infection rate as compared to population
SELECT location, population, MAX(total_cases) as highest_infection, MAX((total_cases/population) * 100) as infected_percentage
FROM CovidDeaths
WHERE total_cases IS NOT NULL AND population IS NOT NULL AND continent IS NOT NULL
GROUP BY location, population
ORDER BY infected_percentage DESC

-- Looking at countries with the highest Death count compared to population
SELECT location, MAX(total_deaths) as total_death_count
FROM CovidDeaths
WHERE total_deaths IS NOT NULL AND continent IS NOT NULL
GROUP BY location
ORDER BY total_death_count DESC

-- Looking at continent with the highest Death count compared to population
SELECT location, MAX(total_deaths) as total_death_count
FROM CovidDeaths
WHERE total_deaths IS NOT NULL AND continent IS NULL
GROUP BY location
ORDER BY total_death_count DESC

SELECT continent, MAX(total_deaths) as total_death_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC

-- Global data
SELECT SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, (SUM(new_deaths)/SUM(new_cases)) * 100 as death_percentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Using CovidVaccinations table 
WITH Pop_vs_Vac (continent, location, date, population)
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) 
OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
FROM CovidDeaths dea 
	JOIN CovidVaccinations vac 
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*10
FROM Pop_vs_Vac

-- Using CovidVaccinations table 
SELECT * 
FROM covidvaccinations

-- Join the 2 tables together
SELECT * 
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
	
-- Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date	
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- Look at the rolling count of the new vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population) * 100 --can't use 'rolling_people_vaccinated' immediately after declaring it
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date	
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3

-- Use CTEfor 'rolling_people_vaccinated'

WITH PopvsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population) * 100 --can't use 'rolling_people_vaccinated' immediately after declaring it
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date	
WHERE dea.continent IS NOT NULL 
-- ORDER BY 2,3
)	

SELECT *, (rolling_people_vaccinated/population) * 100
FROM PopVSVac




-- Temp table
DROP TABLE IF EXISTS percent_population_vaccinated
CREATE TABLE percent_population_vaccinated
(
	continent varchar(255),
	location varchar(255),
	date varchar(255),
	population numeric,
	new_vaccinations numeric,
	rolling_people_vaccinated numeric
);

INSERT INTO percent_population_vaccinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population) * 100 --can't use 'rolling_people_vaccinated' immediately after declaring it
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date	
WHERE dea.continent IS NOT NULL; 


SELECT *, (rolling_people_vaccinated/population) * 100
FROM percent_population_vaccinated


-- Creating view to store data for visualizations

CREATE VIEW percent_population_vaccinated_view AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--, (rolling_people_vaccinated/population) * 100 --can't use 'rolling_people_vaccinated' immediately after declaring it
FROM coviddeaths dea
JOIN covidvaccinations vac
	ON dea.location = vac.location 
	AND dea.date = vac.date	
WHERE dea.continent IS NOT NULL 
--ORDER BY 2,3
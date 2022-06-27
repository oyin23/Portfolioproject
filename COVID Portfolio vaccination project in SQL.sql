SELECT *
FROM [portfolio project].dbo.CovidDeaths
ORDER BY 3,4


--SELECT *
--FROM [portfolio project].dbo.CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths,population
FROM [portfolio project].dbo.CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1,2


--Looking at the Total Cases vs Total Deaths
-- Shows the likely hood of dring if you contract Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_percentage
FROM [portfolio project].dbo.CovidDeaths
WHERE location LIKE '%state%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_cases/population) *100 AS Population_percentage
FROM [portfolio project].dbo.CovidDeaths
WHERE location LIKE '%state%'
ORDER BY 1,2

-- Country that has the highest infection rate compared to population

SELECT location, population,  MAX(total_cases) AS Highest_Infection_Count,MAX((total_cases/population))*100 AS Population_percentage
FROM [portfolio project].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY  location, population
ORDER BY Population_percentage DESC

-- Shows the countries with the highest death count per population

SELECT location, population,  MAX(CAST(total_deaths AS int)) AS Highest_Death_Count
FROM [portfolio project].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY  location, population
ORDER BY Highest_Death_Count DESC

--Break things by continent

SELECT location, MAX(CAST(total_deaths AS int)) AS Highest_Death_Count
FROM [portfolio project].dbo.CovidDeaths
WHERE continent IS NULL
GROUP BY  location
ORDER BY Highest_Death_Count DESC



-- Showing continent with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS Highest_Death_Count
FROM [portfolio project].dbo.CovidDeaths
WHERE continent IS NOT NULL
GROUP BY  continent
ORDER BY Highest_Death_Count DESC

-- Global Numbers of total cases and deaths

SELECT SUM(new_cases) AS sum_cases, SUM(CAST(new_deaths AS int)) AS sum_deaths, SUM(CAST(new_deaths AS int))/SUM
(new_cases) *100 AS Death_percentage
FROM [portfolio project].dbo.CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Covid Vaccinations
SELECT *
FROM [portfolio project].dbo.CovidDeaths dea
JOIN [portfolio project].dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

-- looking at Total population vs vaccinations

WITH PopvsVac (continent, location, date, population, new_vaccinations,
rolling_people_vaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location
ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM [portfolio project].dbo.CovidDeaths dea
JOIN [portfolio project].dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100
FROM PopvsVac

-- Temp Table

DROP TABLE IF exists #Percent_Population_vacinated
CREATE TABLE #Percent_Population_vacinated
(
continent NVARCHAR(255),
location NVARCHAR(255),
Date datetime,
population NUMERIC,
New_vaccinations NUMERIC,
rolling_people_vaccinated NUMERIC
)

INSERT INTO #Percent_Population_vacinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location
ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM [portfolio project].dbo.CovidDeaths dea
JOIN [portfolio project].dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (rolling_people_vaccinated/population)*100
FROM #Percent_Population_vacinated


-- Creating view to store data for later visualization

CREATE VIEW Percent_Population_vacinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS int)) OVER (partition by dea.location
ORDER BY dea.location, dea.date) AS rolling_people_vaccinated
--(rolling_people_vaccinated/population)*100
FROM [portfolio project].dbo.CovidDeaths dea
JOIN [portfolio project].dbo.CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT *
FROM Percent_Population_vacinated
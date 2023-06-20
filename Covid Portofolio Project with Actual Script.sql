SELECT *
FROM PortofolioProject..CovidVactination
ORDER BY 3,4


SELECT location, date, total_cases, new_cases,total_deaths, population
FROM PortofolioProject..CovidDeaths
ORDER BY 1,2

-- Total cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortofolioProject..CovidDeaths
WHERE location = 'INDONESIA' AND (total_deaths/total_cases) is not null
ORDER BY 1,2


-- Total cases vs Population
-- Percentage of Population getting covid

SELECT location, date, population, total_cases, (total_cases/population)*100 PercPopulationInfected
FROM PortofolioProject..CovidDeaths
WHERE location = 'United States' and total_cases IS NOT NULL and population IS NOT NULL
ORDER BY 1,4


-- Total_cases and population column need to be converted to Double Precision because of using bigint always return 0 in calculation
ALTER TABLE PortofolioProject..CovidDeaths
ALTER COLUMN total_cases Double Precision

ALTER TABLE PortofolioProject..CovidDeaths
ALTER COLUMN population Double Precision



-- Looking at Countries with Highest Infection Rate Compared to Population for Population more than 10 millions people

SELECT location, population, MAX(total_cases) as HighestInfCount, Max(total_cases/population)*100 PercPopulationInfected
FROM PortofolioProject..CovidDeaths
WHERE population > 10000000
GROUP BY Location, Population
ORDER BY 4 DESC


-- Highest Death Count per Population

SELECT location, MAX(total_deaths) as TotalDeathCount
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Breaking Down by Continent

SELECT location, MAX(total_deaths) as TotalDeathCount, population
FROM PortofolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location, Population
ORDER BY TotalDeathCount DESC


-- Showing continents with the highest death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount, population
FROM PortofolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location, Population
ORDER BY TotalDeathCount DESC


-- Global Numbers
SELECT date, SUM(new_cases) AS TotalNewCases, SUM(new_deaths) AS TotalCases, NULLIF(SUM(new_deaths), 0)/SUM(new_cases) *100 AS DeathsPerc
FROM PortofolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


--Total Population vs Vaccination

Select DEA.continent, DEA.location, DEA.date, population, VAC.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by Dea.Location ORDER BY Dea.Location, Dea.Date) AS CumPeopleVacc
FROM PortofolioProject..CovidDeaths DEA
JOIN PortofolioProject..CovidVactination VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3

-- CTE
WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, CumPeopleVacc)
AS (
Select DEA.continent, DEA.location, DEA.date, population, VAC.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by Dea.Location ORDER BY Dea.Location, Dea.Date) AS CumPeopleVacc
FROM PortofolioProject..CovidDeaths DEA
JOIN PortofolioProject..CovidVactination VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE dea.continent IS NOT NULL

)
SELECT *, (CumPeopleVacc/Population) AS PercPopulationVacc
FROM PopvsVac
WHERE Location = 'Indonesia'


--TEMP Table

DROP TABLE
IF EXISTS #PercPopulationVacc

Create Table #PercPopulationVacc(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumPeopleVacc numeric
)


INSERT INTO #PercPopulationVacc
Select DEA.continent, DEA.location, DEA.date, population, VAC.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by Dea.Location ORDER BY Dea.Location, Dea.Date) AS CumPeopleVacc
FROM PortofolioProject..CovidDeaths DEA
JOIN PortofolioProject..CovidVactination VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE dea.continent IS NOT NULL

SELECT *, (CumPeopleVacc/Population) AS PercPopulationVacc
FROM #PercPopulationVacc


--Aggregating Percentage of People Vaccinated for Large Country (Over 10 Millions Population)

SELECT Location, Population, Max(CumPeopleVacc/Population) AS MaxPercPopulationVacc
FROM #PercPopulationVacc
GROUP BY Location, Population
HAVING Population> 10000000
ORDER BY MaxPercPopulationVacc DESC

--Creating View to Store Data for Later Visualization

CREATE VIEW PercentPopulationVaccinated AS
Select DEA.continent, DEA.location, DEA.date, population, VAC.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by Dea.Location ORDER BY Dea.Location, Dea.Date) AS CumPeopleVacc
FROM PortofolioProject..CovidDeaths DEA
JOIN PortofolioProject..CovidVactination VAC
	ON DEA.location = VAC.location
	AND DEA.date = VAC.date
WHERE dea.continent IS NOT NULL
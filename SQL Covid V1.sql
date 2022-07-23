SELECT*
FROM SheldonPortfolio..CovidDeaths
WHERE continent is not null
ORDER BY 3,4


SELECT*
FROM SheldonPortfolio..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM SheldonPortfolio..CovidDeaths
WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

--LOOKING AT TOTAL DEATH VS TOTAL CASES
--likelihood of dying if contracted Covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM SheldonPortfolio..CovidDeaths
WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2

--Looking at total cases vs population
--Shows a percentage of the population that contracted Covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationinfected
FROM SheldonPortfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1,2


--looking at countries with highest infection Rate compared to population

SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationinfected
FROM SheldonPortfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentPopulationinfected desc

--Shows Countries with Highest Death per Population

SELECT location, max(cast(total_deaths as int)) as TotalDeathCount
FROM SheldonPortfolio..CovidDeaths
--WHERE location like '%states%'
 WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc

--Showing highest Death per population as Continents
--MUST USE 'CONTINENT IS NULL' TO HAVE CORRECT COUNT
--USING 'CONTINENT IS NOT NULL' DOES NOT INCLUDE ALL COUNTRIES IN A CONTINENT
SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM SheldonPortfolio..CovidDeaths
--WHERE location like '%states%'
 WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Continent with highest death count per population

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM SheldonPortfolio..CovidDeaths
--WHERE location like '%states%'
 WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount Desc

--Global Numbers

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM SheldonPortfolio..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
FROM SheldonPortfolio..CovidDeaths dea
Join SheldonPortfolio..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- USE CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinatated)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM SheldonPortfolio..CovidDeaths dea
Join SheldonPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinatated/Population)*100
FROM PopvsVac
-- TEMP TABLE
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinated numeric,
RollingPeopleVaccinated numeric
)

Insert into 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM SheldonPortfolio..CovidDeaths dea
Join SheldonPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated



--Creating view to store data for later visualization

Create view PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM SheldonPortfolio..CovidDeaths dea
Join SheldonPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
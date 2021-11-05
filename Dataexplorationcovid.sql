SELECT *
FROM CovidProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4
--sqL cho phép s?p x?p d?a v? trí theo v? trí g?c c?a c?t
--SELECT * 
--FROM CovidProject..CovidVaccinations$
--ORDER BY 3,4
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2
-- Looking at the total_cases and total_dealth
-- Show likelihood of dying if you contract covid in your country
SELECT	location,date,total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage 
FROM CovidProject..CovidDeaths$
WHERE location like '%States%'
AND continent is not null
ORDER BY 1,2
-- Looking at Total Cases & population
-- Show what percentage of population got covid
SELECT	location,date,total_cases, population, (total_cases/population)*100 as PopulationPercentage 
FROM CovidProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2
-- Looking at country with highest infection rate compared to population
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS PercentagePopulationInfected
FROM CovidProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationInfected DESC
--Showing countries with highest death count per population
--CAST FUNCTION Convert a value to an int datatype:
SELECT location, population, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

--Showing continents with the highest deaths count per population 
SELECT continent, MAX (CAST(total_deaths AS int))AS TotalDeathCount
FROM CovidProject..CovidDeaths$
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL NUMBERS
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDealth , SUM(CAST(new_deaths AS int)) / SUM(new_cases) AS DeathPersentage
FROM CovidProject..CovidDeaths$
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS int)) AS TotalDealth , SUM(CAST(new_deaths AS int)) / SUM(new_cases) AS DeathPersentage
FROM CovidProject..CovidDeaths$
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at Total Population and vaccination
--The GROUP BY clause reduces the number of rows returned by rolling them up and calculating the sums or averages for each group.
--The PARTITION BY clause divides the result set into partitions and changes how the window function is calculated. The PARTITION BY clause does not reduce the number of rows returned.
--https://www.mssqltips.com/sqlservertip/6971/sql-cast-sql-convert-function/ 
--https://www.sqlshack.com/sql-convert-date-functions-and-formats/
--CAST(expression AS datatype(length)), CONVERT(datatype(length), expression, style)
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date 
WHERE dea.continent is not null
ORDER BY 2,3

--USE Common Table Expression (CTE):  n?i chúng ta l?u tr? b?ng d? li?u ???c truy xu?t m?t cách t?m th?i trong b? nh? d??i m?t cái tên ?? chúng ta có th? dùng l?i v? sau.
--It like Function in Python, L?nh WITH trong SQL chính là cú pháp ?? chúng ta s? d?ng ch?c n?ng CTE trong MySQL. https://data-fun.com/mysql-common-table-expression-with/

WITH PopvsVac (Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date 
WHERE dea.continent is not null
)
SELECT * , (RollingPeopleVaccinated/Population )*100
FROM PopvsVac

--TEMP TABLE (Temporary Table): store temporary data, they can be deleted when the current Client Session ends
DROP TABLE IF exists #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated
(
Continent nvarchar(255)
,Location nvarchar(255)
,Date datetime
,population numeric
,new_vaccinations numeric
, RollingPeopleVaccinated numeric)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date 
--WHERE dea.continent is not null

SELECT * , (RollingPeopleVaccinated/Population )*100
FROM #PercentPopulationVaccinated

--Create view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidProject..CovidDeaths$ dea
JOIN CovidProject..CovidVaccinations$ vac
ON dea.location=vac.location
AND dea.date=vac.date 
WHERE dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated

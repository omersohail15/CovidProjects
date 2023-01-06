/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  *
FROM covid_project..covid_deaths
WHERE continent is not null
ORDER BY 3,4

  --SELECT  *
  --FROM covid_project..covid_vaccinations
  --ORDER BY 3,4

  --select data that we are going to be use

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM covid_project..covid_deaths
WHERE continent is not null
ORDER BY 1,2

--total_cases vs total_deaths

--show the likely hood died in your country

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deaths_percentage
FROM covid_project..covid_deaths
WHERE continent is not null
AND location like '%states%'
ORDER BY 1,2

--total_case4s vs population

--show what percentage of population got  covid

SELECT location,date,population,total_cases,(total_cases/population)*100 as deaths_percentage
FROM covid_project..covid_deaths
--WHERE location like '%states%'
ORDER BY 1,2

--looking at country's highest infected rate compared to populations

SELECT location,population,MAX(total_cases) as HighestInfectionCount,
MAX((total_cases/population))*100 as percentPopulationInfected
FROM covid_project..covid_deaths
--WHERE location like '%states%'
GROUP BY location,population
ORDER BY percentPopulationInfected desc

--showing the country's with highest death count per population

SELECT location,MAX(cast(total_deaths as int)) as totaldeathcount
FROM covid_project..covid_deaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY totaldeathcount desc

--LETS BREAK things down with continents

--showing the continents with hihest death count per population

SELECT continent,MAX(cast(total_deaths as int)) as totaldeathcount
FROM covid_project..covid_deaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY totaldeathcount desc


--GOLOBAL NUMBERS

SELECT SUM(new_cases) as total_cases,
SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as deaths_percentage
FROM covid_project..covid_deaths
--AND location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--looking at total population vs vaccinations

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) 
OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated

FROM covid_project..covid_deaths dea
JOIN covid_project..covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
--, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From covid_project..covid_deaths dea
--Join covid_project..covid_vaccinations vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

--WITH CTE
WITH popvsvac (continent,location,date,population,RollingPeopleVaccinated,new_vaccinations) as 
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) 
OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated

FROM covid_project..covid_deaths dea
JOIN covid_project..covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population) * 100
FROM popvsvac


--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
 continent nvarchar(255),
 location nvarchar(255),
 DATE datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) 
OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated

FROM covid_project..covid_deaths dea
JOIN covid_project..covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population) * 100
FROM #PercentPopulationVaccinated

--Creating view to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations as bigint)) 
OVER(PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingPeopleVaccinated

FROM covid_project..covid_deaths dea
JOIN covid_project..covid_vaccinations vac
	ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

select * from PercentPopulationVaccinated



SELECT 
    location,date,total_cases,total_deaths,
    (total_deaths / NULLIF(total_cases, 0)) * 100 AS DeathPercentage
FROM CovidDeaths
where location like '%nepal%'


--total case vs population
SELECT 
    location,continent,date,total_cases,population,
    (total_cases/nullif(population,0)) * 100 AS PercentagePopulationInfected
FROM CovidDeaths
where location like '%NEPAL%'

--countries with the highest infected population
SELECT 
    location,population,MAX(total_cases) as HighestInfectCount,
    MAX((total_cases/nullif(population,0))) * 100 AS PercentagePopulationInfected
FROM CovidDeaths
--where location like '%NEPAL%'
Where continent is not null
Group by population,location,continent
order  by PercentagePopulationInfected Desc

--countries with highest death count
SELECT 
    location,MAX(total_deaths) as TotalDeathCount
    
FROM CovidDeaths
where continent is not null
Group by location
order  by TotalDeathCount Desc

--Showing continent with highest death count
SELECT   location,MAX(total_deaths) as TotalDeathCount
    FROM CovidDeaths
where continent is not  null
Group by continent
order  by TotalDeathCount Desc



--breaking global numbers
SELECT 
    Sum(new_cases)AS totalCases,Sum(cast(new_deaths as int))AS totalDeaths,Sum(cast(new_deaths as int))/Sum(new_cases) *100  as DeathPercentage
FROM CovidDeaths 
where  continent is not null

--Group by date
order by totalCases ASC

--Looking At total Population VS VACCINATIONS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int))Over (Partition by dea.location Order by dea.location, dea.date ) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Use CTE
with PopvsVac(Continent,Location,Date,population,new_vaccinations,RollingPeopleVacinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int))Over (Partition by dea.location Order by dea.location, dea.date ) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)
SELECT *,(RollingPeopleVacinated/population)*100
FROM PopvsVac

--Temp
Drop Table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent varchar (255),
location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinate numeric
)
Insert Into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int))Over (Partition by dea.location Order by dea.location, dea.date ) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

SELECT *,(RollingPeopleVaccinate/population)*100
FROM #PercentPopulationVaccinated

--Create  View to store DATA FOR LATER VISUALIZATION
Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int))Over (Partition by dea.location Order by dea.location, dea.date ) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * from
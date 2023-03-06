--select location, date, total_cases, new_cases, total_deaths, population
--from PortfolioProject..['Covid_Deaths$']
--order by 1,2

--looking total case vs total deaths

-- shows report of people dying in you country
--select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
--from PortfolioProject..['Covid_Deaths$']
--where location like '%India%'
--order by 1,2

-- percentage of polulation got covid
--select location, date,population, total_cases, total_deaths, (total_cases/population)*100 as Infection_Rate
--from PortfolioProject..['Covid_Deaths$']
--where location like '%states%'
--order by 1,2


--country with highest infection rate 
--select location, population, max(total_cases) as MaxTotalCases, max((total_cases/population))*100 as Max_Infection_Rate
--from PortfolioProject..['Covid_Deaths$']
--Group by population,location
--order by  Max_Infection_Rate desc

--total death by continent highest
--select continent, max(cast(total_deaths as int)) as MaxTotalDeath
--from PortfolioProject..['Covid_Deaths$']
--where continent is not null 
--Group by continent
--order by MaxTotalDeath desc

--Global Numbers
--select date, sum(new_cases) as Total_Cases, sum(cast(new_deaths as bigint)) as Total_Deaths, 
--sum(cast(new_deaths as bigint))/sum(new_cases)*100 as Death_Percentage
--from PortfolioProject..['Covid_Deaths$']
--where continent is not null
--Group By date
--order by 1,2

--Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
-- SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--From PortfolioProject..['Covid_Deaths$'] dea
--Join PortfolioProject..['Covid_vaxinations$'] vac
--	On dea.location = vac.location
--	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid_Deaths$'] dea
Join PortfolioProject..['Covid_vaxinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid_Deaths$'] dea
Join PortfolioProject..['Covid_vaxinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3


Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..['Covid_Deaths$'] dea
Join PortfolioProject..['Covid_vaxinations$'] vac
	On dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null 
select * 
from PortfolioProject..Covid_Deaths$
order by 3,4

--select data that we are going to be using
select location,date,population,total_cases,new_cases,total_deaths
from PortfolioProject..Covid_Deaths$
where location like '%India%'
order by 1,2

--looking at total cases vs total deaths
select location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..Covid_Deaths$
where location like '%India%'
order by 1,2

--looking at total cases vs population
--shows what % of population got covid
select location,date, population,total_cases,( total_cases/population)*100 as PopulationPercentage
from PortfolioProject..Covid_Deaths$
where location like '%India%'
order by 1,2

--looking at countries with highest infection rate compared to population
select location,population,max(total_cases) as highestInfectedCount ,max((total_cases/population))*100 as percentPopulationInfected
from PortfolioProject..Covid_Deaths$
--where location like '%India%'
where continent is not null
group by location,population
order by percentPopulationInfected desc

--showing countries with highest daeth count per population
select location, max(cast(Total_Deaths as int)) as totalDeathCount
from PortfolioProject..Covid_Deaths$
--where location like '%India%'
where continent is not null
group by location,population
order by totalDeathCount desc

--lets break things down by continent
select location, max(cast(Total_Deaths as int)) as totalDeathCount
from PortfolioProject..Covid_Deaths$
--where location like '%India%'
where continent is not null
group by location,population
order by totalDeathCount desc

--showing continents with highest death count per population
select continent, max(cast(Total_Deaths as int)) as totalDeathCount
from PortfolioProject..Covid_Deaths$
--where location like '%India%'
where continent is not null
group by continent
order by totalDeathCount desc

--global numbers
select date,sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercentage
from PortfolioProject..Covid_Deaths$
--where location like '%India%'
where continent is not null
group by date
order by 1,2

--looking at total population vs vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
order by 2,3



--use CTE to perform Calculation on Partition By in previous query

with PopVsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(select dea.continent, dea.location ,dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int)) 
over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..Covid_Deaths$ dea
join PortfolioProject..Covid_Vaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopVsVac


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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..Covid_Deaths$ dea
Join PortfolioProject..Covid_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

select * from PercentPopulationVaccinated

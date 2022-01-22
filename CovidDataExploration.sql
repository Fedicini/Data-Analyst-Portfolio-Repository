select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as PercentDeathRate
from PortfolioProject..CovidDeaths
where location like'%states%'
order by 1,2

-- Looking at the total cases vs the population

select Location, date, total_cases, Population, (total_cases/population)*100 as CasesToPopulationRatio
from PortfolioProject..CovidDeaths
where location like'%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

select Location, Population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- where location like'%states%'
Group by Location, Population
order by PercentPopulationInfected

-- Showing Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
Group by location
order by TotalDeathCount desc

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

select SUM(new_cases) as totalcases, SUM(cast(new_deaths as int)) as totaldeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2


-- Looking at total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3

	
	Drop Table if exists #PercentPopulationVaccinated
	Create Table #PercentPopulationVaccinated
	(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_Vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

	Insert into #PercentPopulationVaccinated 
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
	order by 2,3
	Select*, (RollingPeopleVaccinated/Population)*100 as PercentPopulationVaxxed
	From #PercentPopulationVaccinated


	Create View PercentPopulationVaccinated as
	select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(convert(bigint, vac.new_vaccinations )) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
	from PortfolioProject..CovidDeaths dea
	join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null

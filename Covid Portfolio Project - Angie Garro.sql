/*
In this project, I explore the impact of Covid-19 using data from 2021, fully aware 
that circumstances have evolved by 2023. My focus is on the pandemic's global effects, 
with detailed analyses for countries like Costa Rica and the United States. 
I aim to reveal how Covid-19 has reshaped health, economy, and society, 
offering insights into its multifaceted influence and illustrating the challenges 
and responses at both global and national levels.
*/

Select *
From PortfolioProject..CovidDeaths
Where continent is not null
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4

-- Total Cases vs Total Deaths
	-- Worldwide
	Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Order by 1,2;

	-- Costa Rica
	Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where location like '%costa%'
	Order by 1,2;

	-- United States
	Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where location like '%states%'
	Order by 1,2;


-- Total Cases vs Population
	-- Worldwide
	Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Order by 1,2;

	-- Costa Rica
	Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where location like '%costa%'
	Order by 1,2;

	-- United States
	Select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where location like '%states%'
	Order by 1,2;


-- Highest infection rate / Population
	-- Worldwide
	Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group By location, population
	Order by PercentPopulationInfected desc;

	-- Costa Rica
	Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
	From PortfolioProject..CovidDeaths
	Where location like '%costa%'
	Group By location, population
	Order by PercentPopulationInfected;

	-- United States
	Select location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
	From PortfolioProject..CovidDeaths
	Where location like '%states%'
	Group By location, population
	Order by PercentPopulationInfected;

-- Highest death rate / Population
	-- Worldwide
	Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Group By location, population
	Order by TotalDeathCount desc;

	-- Costa Rica
	Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where location like '%costa%'
	Group By location, population
	Order by TotalDeathCount;

	-- United States
	Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where location like '%states%'
	Group By location, population
	Order by TotalDeathCount;
	

-- Highest death rate / Population by Continent
	Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is null
	Group By location
	Order by TotalDeathCount desc;

-- Highest death rate / Population Worldwide
	Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where continent is not null
	Order by 1,2;


-- Total population vs vaccinations
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
	, SUM(Convert(int, Vac.new_vaccinations)) OVER (Partition by Dea.Location Order by dea.location, dea.date) as Rolling_People_Vaccinated
	, (Rolling_People_Vaccinated)*100
From PortfolioProject..CovidVaccinations Vac
Join PortfolioProject..CovidDeaths Dea
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where dea.continent is not null
order by 2,3;

-- WITH CTE (Common Table Expression)
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(

Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
	, SUM(Convert(int, Vac.new_vaccinations)) OVER (Partition by Dea.Location Order by dea.location, dea.date) as Rolling_People_Vaccinated
	--, (Rolling_People_Vaccinated)*100
From PortfolioProject..CovidVaccinations Vac
Join PortfolioProject..CovidDeaths Dea
	On Dea.location = Vac.location
	and Dea.date = Vac.date
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- WITH TEMP
Drop Table if exists PercentPopulationVaccinated
Create Table PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population Numeric, 
New_Vaccinations Numeric,
RollingPeopleVaccinated Numeric
)

Insert into PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
	, SUM(Convert(int, Vac.new_vaccinations)) OVER (Partition by Dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations Vac
Join PortfolioProject..CovidDeaths Dea
	On Dea.location = Vac.location
	and Dea.date = Vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From PercentPopulationVaccinated


-- View for a later visualization

Create View PerPopulationVaccinated
AS
Select Dea.continent, Dea.location, Dea.date, Dea.population, Vac.new_vaccinations
	, SUM(Convert(int, Vac.new_vaccinations)) OVER (Partition by Dea.Location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidVaccinations Vac
Join PortfolioProject..CovidDeaths Dea
	On Dea.location = Vac.location
	and Dea.date = Vac.date
Where Dea.continent is not null

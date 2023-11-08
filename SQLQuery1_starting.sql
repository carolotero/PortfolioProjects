Select *
From ProjectPortfolio..CovidDeaths
order by 3,4

--Select *
--From ProjectPortfolio..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using

Select 
location, 
date, 
total_cases, 
new_cases, 
total_deaths, 
population
From ProjectPortfolio..CovidDeaths
order by 1,2

--Looking at Total cases vs Total Deaths
--Shows likelyhood of dying if you contract covid in your country

Select 
location, 
date, 
total_cases, 
total_deaths, 
CONVERT(DECIMAL(18, 5), (CONVERT(DECIMAL(18, 5), total_deaths) / CONVERT(DECIMAL(18, 5), total_cases))) * 100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
Where location like '%States%'
order by 1,2

-- Looking at Total_cases vs Population
--Shows what percentage of population got Covid

Select 
location, 
date, 
population,
total_cases, 
CONVERT(DECIMAL(18, 5), (CONVERT(DECIMAL(18, 5), total_cases) / CONVERT(DECIMAL(18, 5), population))) * 100 as CasesPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%States%'
order by 1,2

--Looking at Countries with highest infection rate compared to population

Select 
location, 
population,
MAX(total_cases) AS HighestInfectionCount, 
MAX(CONVERT(DECIMAL(18, 5), (CONVERT(DECIMAL(18, 5), total_cases) / CONVERT(DECIMAL(18, 5), population)))) * 100 as CasesPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%States%'
Group by location, population
order by CasesPercentage DESC

--Showing countries with highest death count per population

Select 
location, 
MAX(CAST(total_deaths AS float)) AS TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent IS NOT NULL
Group by location
order by TotalDeathCount DESC

-- Let's break things down by continent

-- Showing the continents with the highest death count per population

Select 
continent, 
MAX(CAST(total_deaths AS float)) AS TotalDeathCount
From ProjectPortfolio..CovidDeaths
Where continent IS NOT NULL
Group by continent
order by TotalDeathCount DESC

--GLOBAL NUMBERS

Select 
--date, 
sum(CAST(new_cases AS FLOAT)) AS total_cases, 
sum(CAST(new_deaths AS FLOAT)) AS total_deaths, 
sum(CAST(new_deaths AS FLOAT)) / sum(CAST(new_cases AS FLOAT)) * 100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%States%'
Where continent is not null
--Group by date
order by 1,2

--Looking at total population vs vaccinations
Select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- USE CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
 (
Select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP TABLE 1

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
Select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- TEMP TABLE 2

DROP Table if exists #PercentPopulationVaccinated2
Create Table #PercentPopulationVaccinated2
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated2
Select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated2


--CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

Create View PercentPopulationVaccinated as 
Select
dea.continent,
dea.location,
dea.date,
dea.population,
vac.new_vaccinations,
sum(convert(float,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.Location, dea.date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated
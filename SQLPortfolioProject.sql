Select*
From CovidDeaths
Order by 1,2

Delete From CovidDeaths
Where continent like '%%'

--Select*
--From CovidVaccination


--Total cases vs total deaths by country

Select location, date, total_cases, total_deaths, (CAST(total_deaths AS decimal(18,0))/CAST(total_cases AS decimal(18,0)))*100 As DeathPercentage
From CovidDeaths
Where location like '%Argentina%' and continent is not null
Order by 1,2

--Total cases vs population

Select location, date, total_cases, population, (CAST(total_cases AS decimal(18,0))/CAST(population AS decimal(18,0)))*100 As CasesPercentage
From CovidDeaths
Where location like '%Argentina%' and continent is not null
Order by 1,2

--Looking at countries with highest infection rate compared to population

Select location, population, MAX(CAST(total_cases AS decimal(18,0))) As HighestInfectionCount,  MAX((CAST(total_cases AS decimal(18,0))/CAST(population AS decimal(18,0))))*100 As PercentPopulationInfected
From CovidDeaths
Where continent is not null
Group By location, population
Order by PercentPopulationInfected desc

--Showing countries with highest death per population

Select location, population, MAX(CAST(total_deaths AS int)) As HighestDeathCount,  MAX((CAST(total_deaths AS decimal(18,0))/CAST(population AS decimal(18,0))))*100 As PercentPopulationDeath
From CovidDeaths
Where continent is not null
Group By location, population
Order by PercentPopulationDeath desc

--By continent


Select continent, MAX(CAST(total_deaths AS int)) As HighestDeathCount,  MAX((CAST(total_deaths AS decimal(18,0))/CAST(population AS decimal(18,0))))*100 As PercentPopulationDeath
From CovidDeaths
Where continent is not null
Group by continent
Order by PercentPopulationDeath desc

--GLOBAL NUMBERS

Select location, date, SUM(CAST(new_cases AS decimal(18,0))) As TotalCases, SUM(CAST(total_cases AS decimal(18,0))) As TotalCasesByDay, SUM(new_deaths)/ NULLIF(SUM(new_cases),0)*100  As DeathPercentage
From CovidDeaths
Where continent is not null
Group by location, date
Order by 1,2

Select SUM(new_cases) As TotalCases, SUM(new_deaths) As TotalDeaths,  SUM(new_deaths)/SUM(new_cases)
From CovidDeaths

--Looking at total populations vs vaccinations

Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS float)) Over (Partition by cd.location Order by cd.location, cd.date) As RollingPeopleVaccinated

From CovidDeaths As cd
Join CovidVaccination as cv
	ON cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null and cd.location like '%Albania%'
Order by 2,3

--USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations ,RollingPeopleVaccinated)
as
(
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS float)) Over (Partition by cd.location Order by cd.location, cd.date) As RollingPeopleVaccinated
From CovidDeaths As cd
Join CovidVaccination as cv
	ON cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--Order by 2,3
)
Select*,(RollingPeopleVaccinated/Population)*100
From PopvsVac

-- TEMP table

DROP Table if exists #PercentPopulationVaccinatedd
Create Table #PercentPopulationVaccinatedd
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population float,
	New_vaccination float,
	RollingPeopleVaccinated float
)
Insert into #PercentPopulationVaccinatedd
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS float)) Over (Partition by cd.location Order by cd.location, cd.date) As RollingPeopleVaccinated
From CovidDeaths As cd
Join CovidVaccination as cv
	ON cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 


Select*
From #PercentPopulationVaccinatedd


-- Creating view to store data for later visualizations

Create view PercentPopulationVaccinatedd As
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST(cv.new_vaccinations AS float)) Over (Partition by cd.location Order by cd.location, cd.date) As RollingPeopleVaccinated
From CovidDeaths As cd
Join CovidVaccination as cv
	ON cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null 

Select*
from PercentPopulationVaccinatedd
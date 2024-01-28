SELECT 
    *
FROM
    portfolioproject.coviddeathss
ORDER BY 3 , 4; 

SELECT 
    *
FROM
    portfolioproject.covidvaccinations
ORDER BY 3 , 4;

#first query
SELECT 
    location,
    date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM
    portfolioproject.coviddeathss
ORDER BY 1, 2;
    
#Total cases vs. Total deaths
#Shows likelihood of dying If you contract covid in your country
SELECT 
    location,
    date,
    total_cases,
    total_deaths,
    (total_deaths / total_cases) * 100 AS Death_percentage
FROM
    portfolioproject.coviddeathss
WHERE
    location LIKE '%states%'
ORDER BY 1, 2;
    
    
#Total cases vs. Population
#Percentage of population that contracted covid
SELECT 
    location,
    date,
    population,
    total_cases,
    (total_cases / population) * 100 AS PercentPoulationInfected
FROM
    portfolioproject.coviddeathss
#WHERE location LIKE '%states%'
ORDER BY 1, 2;

#Countries with Highest Infection rate compared to population
SELECT 
    location,
    population,
    MAX(total_cases) AS HighestInfectionCount,
    MAX(total_cases / population) * 100 AS PercentPoulationInfected
FROM
    portfolioproject.coviddeathss
GROUP BY
	location, population
ORDER BY PercentPoulationInfected DESC;
    
#Showing Countries with Highest Death count per population
SELECT 
    location,
    MAX(CAST(total_deaths AS signed)) AS TotalDeathCount
FROM
    portfolioproject.coviddeathss
WHERE
	continent is NOT NULL
GROUP BY
	location
ORDER BY TotalDeathCount DESC;


#Breaking things down by continent
#Showing continents with the highest death count per population
SELECT 
    continent,
    MAX(CAST(total_deaths AS signed)) AS TotalDeathCount
FROM
    portfolioproject.coviddeathss
WHERE
	continent is not NULL
GROUP BY
	continent
ORDER BY TotalDeathCount DESC;

#Global Numbers
SELECT 
    SUM(new_cases) as total_cases,
    SUM(Cast(new_deaths as signed)) AS total_deaths,
    SUM(Cast(new_deaths as signed)) / SUM(new_cases) * 100 AS DeathPercentage
FROM
    portfolioproject.coviddeathss
WHERE
    continent is not NULL
ORDER BY 1, 2;

#Looking at Total Population vs. Vaccinations
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(convert(new_vaccinations, signed)) OVER (partition by d.location order by d.location, d.date) RollingPeopleVaccinated
From  portfolioproject.coviddeathss d
JOIN  portfolioproject.covidvaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not NULL
ORDER BY d.location, d.date;

#CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
AS
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(convert(new_vaccinations, signed)) OVER (partition by d.location order by d.location, d.date) RollingPeopleVaccinated
From  portfolioproject.coviddeathss d
JOIN  portfolioproject.covidvaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not NULL
)
Select * , (RollingPeopleVaccinated/Population)*100 
From PopvsVac;

#Temp Table
DROP TABLE portfolioproject.PercentPopulationVaccinated;

CREATE TABLE portfolioproject.PercentPopulationVaccinated 
(
continent char(255),
location char(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);

INSERT into portfolioproject.PercentPopulationVaccinated 
(
Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(convert(new_vaccinations, signed)) OVER (partition by d.location order by d.location, d.date) RollingPeopleVaccinated
From  portfolioproject.coviddeathss d
JOIN  portfolioproject.covidvaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not NULL
);
Select * , (RollingPeopleVaccinated/Population)*100 
From portfolioproject.PercentPopulationVaccinated;

#Creating a view 
CREATE VIEW  portfolioproject.PercentPopulationVaccinated AS Select d.continent, d.location, d.date, d.population, v.new_vaccinations, SUM(convert(new_vaccinations, signed)) OVER (partition by d.location order by d.location, d.date) RollingPeopleVaccinated
From  portfolioproject.coviddeathss d
JOIN  portfolioproject.covidvaccinations v
ON d.location = v.location
AND d.date = v.date
WHERE d.continent is not NULL

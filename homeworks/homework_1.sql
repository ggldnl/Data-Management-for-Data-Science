
/* ----------------------------- world countries ---------------------------- */

drop table if exists world_countries cascade;

-- consists of data such as population, land area, density, fertility rate and soo on for each country
create table world_countries(
	alpha_3 varchar,
	country varchar,
	population2020 numeric,
	yearly_change numeric,
	net_change numeric,
	density numeric,
	land_area numeric,
	migrants numeric,
	fert_rate numeric,
	med_age numeric,
	urban numeric,
	world_share numeric,
	region varchar
);

copy world_countries(
	alpha_3, 
	country, 
	population2020, 
	yearly_change, 
	net_change, 
	density, 
	land_area, 
	migrants,
	fert_rate,
	med_age, 
	urban,
	world_share,
	region
)
from '/tmp/world_countries.csv'
with delimiter as ',' null as 'nan' csv header;

select * from world_countries;

/* --------------------------- country territories -------------------------- */

drop table if exists country_territories cascade;

-- geographical information for each country
create table country_territories (
	country varchar,
	alpha_2 varchar, 
	alpha_3 varchar,
	region varchar,
	subregion varchar,
	intermediate_region varchar
);

copy country_territories(
	country,
	alpha_2,
	alpha_3,
	region,
	subregion,
	intermediate_region
)
from '/tmp/country_territories.csv'
with delimiter as ',' null as 'NULL' csv header;

select * from country_territories;

/* ------------------------------ eu countries ------------------------------ */

drop table if exists eu_countries cascade;

-- countries that are in the european union
create table eu_countries (
    alpha_3 varchar ,
    country varchar,
    capital varchar,
    gdp float, -- gross domestic product
    join_date date,
	currency varchar
);

copy eu_countries (
	alpha_3,
	country,
	capital,
	gdp,
	join_date,
	currency
)
from '/tmp/eu_countries.csv'
with delimiter as ',' null as 'NULL' csv header;

select * from eu_countries;

/* ------------------------------ co2 emissions ----------------------------- */

drop table if exists co2_emissions cascade;

-- co2 emissions from 1750 to 2021 for each country. 
-- Emissions are divided into coal, oil, ect.  
create table co2_emissions (
	country varchar,
	alpha_3 varchar,
	ref_year numeric ,
	total numeric,
	coal numeric,
	oil numeric,
	gas numeric,
	cement numeric,
	flaring numeric,
	other numeric,
	per_capita numeric
);

copy co2_emissions (
	country,
	alpha_3,
	ref_year ,
	total,
	coal,
	oil,
	gas,
	cement,
	flaring,
	other,
	per_capita
)
from '/tmp/co2_emissions.csv'
with delimiter as ',' null as 'NULL' csv header;

select * from co2_emissions;

/* --------------------------------- queries -------------------------------- */

-- 1. Return the name of country the regions and the medage with medage lower than 30

select country, med_age, region, fert_rate 
from world_countries 
group by country, med_age, region, fert_rate
having med_age < 30 
order by region, med_age; -- the higher the fertility rate, the lower the average age

-- 2. Return countries and their subregion that are in Europe but not in the
-- European Union

-- All the countries that are in Europe but not in the European Union -> 22
select country, subregion
from country_territories ct
where ct.alpha_3 not in (
	select eu.alpha_3
	from eu_countries eu
)
group by subregion, country, region
having ct.region = 'Europe'
order by subregion;

select count(country) as total from eu_countries; -- 27
select count(country) as total from world_countries where region = 'Europe'; -- 48
-- we should have 48 - 27 = 21 countries 

-- 3. Return all the countries in the european union that are not geographically in europe 

select wc.alpha_3, wc.country, wc.region, eu.join_date, eu.currency
from eu_countries eu, world_countries wc
where 
	eu.alpha_3 = wc.alpha_3 and
	wc.region != 'Europe'; -- Cyprus

-- 4. For the top 10 populated countries return country, population, land area and density 

--density = p/km^2
--land area = km^2

select 
	country,
	to_char(population2020, 'FM999G999G999G999') as population2020,
	to_char(land_area, 'FM999G999G999G999') as land_area,
	density,
	population2020 / land_area as computed_density
from world_countries wc
where land_area > 0
order by wc.population2020 desc
limit 10;

-- 5. for every region return the average of population for region 
-- and the most populated country

select 
	avgp.region, 
	to_char(round(avgp.avg, 2), 'FM999G999G999D99') as average_Population,
	to_char(round(sump.sum, 2), 'FM999G999G999G999') as sum_Population,
	mpc.country, 
	to_char(mpc.population2020, 'FM999G999G999G999') as population
from 
	(select wc.region, avg(wc.population2020)
	from world_countries wc
	group by wc.region) avgp,
	(select wc.region, sum(wc.population2020)
	from world_countries wc
	group by wc.region) sump,
	(select wc.country, wc.population2020, wc.region
		from world_countries wc
		join (
			select  max(population2020) as maxp, region
			from world_countries
			group by region
		) wc1 on wc.region = wc1.region and wc.population2020 = wc1.maxp) mpc 
where avgp.region = mpc.region and sump.region = mpc.region
order by average_population desc;

-- 6. Return world countries that have a greater population density of the most
-- densely populated african country

-- We took Africa as continent because it has a relatively low population density, 
-- so to have a lot of results

-- density = p/km^2

select wc.alpha_3, wc.country, wc.density
from world_countries wc
where wc.density > (
	select max(wc1.density)
	from world_countries wc1
	where wc1.region = 'Africa'
)
order by wc.density desc;

-- 7. Return the country polulation of every country such that the total amount of
-- coal emissions from 2010 to 2020 is less than 100

-- co2 emissions are measured in million metric tons (MMT)

select wc.country, wc.population2020, sum(co2.coal) as total_emissions
from world_countries wc, co2_emissions co2
where
	co2.coal is not null and
	wc.alpha_3 = co2.alpha_3 and 
	co2.ref_year between 2010 and 2020 
group by wc.alpha_3, wc.country, wc.population2020
having
	sum(co2.coal) < 100
order by total_emissions desc;

-- 8. Return country population and total emissions of the top 10 
--countries of CO2 emissions of coal from 2010 to 2020

select wc.country, wc.population2020, sum(co2.coal) as total_emissions, wc.region
from world_countries wc, co2_emissions co2
where 
	co2.coal is not null and 
	wc.alpha_3 = co2.alpha_3 and 
	co2.ref_year between 2010 and 2020
group by wc.country, wc.population2020, wc.region
order by total_emissions desc
limit 10;

-- 9. Return the difference in percentage of emissions of a country between 2010 and 2020

select 
	e10.alpha_3, 
	e10.country,
	wc.region,
	e10.emissions2010, 
	e20.emissions2020,
	round(((e20.emissions2020 - e10.emissions2010) / e10.emissions2010) * 100, 2) as percentage
from 
	(select alpha_3, country, total as emissions2010
		from co2_emissions
		where ref_year = 2010) e10, 
	(select alpha_3, country, total as emissions2020
		from co2_emissions
		where ref_year = 2020) e20, 
	world_countries wc
where 
	e10.alpha_3 = wc.alpha_3 and
	e10.alpha_3 = e20.alpha_3 and
	e10.emissions2010 > 0 and
	e20.emissions2020 > 0
order by percentage;

-- 10. Return the maximum emission, the year and the region for each country

-- for each country, return its region and the year in which it produced the most co2 emissions
select a.alpha_3, a.country, a.ref_year, a.total, wc.region
from world_countries wc, co2_emissions a
left outer join co2_emissions b
    on a.alpha_3 = b.alpha_3 and
	a.total < b.total
where b.alpha_3 is null and wc.alpha_3 = a.alpha_3
order by a.ref_year desc;

-- 11. Return region and subregion with the number of countries > 10

select *
from 
	(select ct.region, ct.subregion, count(ct.country) as num_countries
		from country_territories ct
		group by ct.region, ct.subregion
		order by num_countries desc) num_countries_for_subregion
where num_countries > 10;

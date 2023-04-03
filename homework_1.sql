
/* ----------------------------- world countries ---------------------------- */

drop table if exists world_countries cascade;

create table world_countries(
	alpha_3 varchar primary key,
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

create table country_territories (
	country varchar,
	alpha_2 varchar, 
	alpha_3 varchar primary key,
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

create table eu_countries (
    alpha_3 varchar primary key,
    country varchar,
    capital varchar,
    gdp float,
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
	per_capita numeric,
	primary key (country, ref_year)
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

-- 1. Return the name of country and the medage with medage lower then 30
select country, region, med_age
from world_countries 
group by country, med_age, region
having med_age < '30' 
order by (region, med_age);

-- 2. Retun countries and their subregion that are in Europe but not in the
-- European Union
select country, subregion
from country_territories ct
where ct.alpha_3 not in (
	select eu.alpha_3
	from eu_countries eu
)
group by country, region, subregion
having ct.region = 'Europe'
order by subregion;


-- 3. Return all the european countries that are not part of the european union and 
-- have population > threshold (5000)
select wc.country, wc.population2020
from world_countries wc
where
	wc.region = 'Europe' and
	wc.alpha_3 not in (
		select eu.alpha_3
		from eu_countries eu
	) and 
	wc.population2020 > 5000
group by wc.country, wc.population2020, wc.region
having wc.region = 'Europe'
order by wc.population2020 desc;

-- 4. Return the country polulation and subregion of every country such that the total amount of
-- Coal co2Emission from 2010 t0 2020 is less than "number";

-- co2 emissions are measured in million metric tons (MMT)
select wc.country, wc.population2020, sum(co2.coal) as total_emissions_MMT
from world_countries wc, co2_emissions co2
where
	co2.coal is not null and
	wc.alpha_3 = co2.alpha_3 and 
	co2.ref_year between 2010 and 2020 
group by wc.alpha_3, wc.country, wc.population2020
having sum(co2.coal) < 100
order by total_emissions_MMT desc;

-- 5. Return all the countries in the european union that are not geographically in europe 
-- (maybe Asia like Cyprus)

select wc.alpha_3, wc.country, wc.region
from eu_countries eu, world_countries wc
where 
	eu.alpha_3 = wc.alpha_3 and
	wc.region != 'Europe';

-- 6. For the top 10 region return country, population, land area and density 
select country, population2020, land_area, density
from world_countries wc
order by wc.population2020 desc
limit 10;

-- 7. for every region return the average of population for region 
-- and the most populated country

drop view if exists most_populated_country;
create view most_populated_country as
select wc.country, wc.population2020, wc.region
from world_countries wc
inner join (
	select  max(population2020) as maxp, region
	from world_countries
	group by region
) wc1 on wc.region = wc1.region and wc.population2020 = wc1.maxp;

drop view if exists avg_population;
create view avg_population as
select wc.region, avg(wc.population2020)
from world_countries wc
group by wc.region;

select 
	avgp.region, 
	to_char(round(avgp.avg, 2), 'FM999G999G999D99') as average_Population, 
	mpc.country, 
	to_char(mpc.population2020, 'FM999G999G999G999') as population
from avg_population avgp, most_populated_country mpc 
where avgp.region = mpc.region;

-- 8. Return region and subregion with the number of countries > threshold

-- drop view if exists num_countries_for_subregion;
-- create view num_countries_for_subregion as
-- select ct.region, ct.subregion, count(ct.country) as num_countries
-- from country_territories ct
-- group by ct.region, ct.subregion
-- order by num_countries desc;
-- 
-- select *
-- from num_countries_for_subregion
-- where num_countries > 10;

--med 10 execution 110,7
select *
from 
(select ct.region, ct.subregion, count(ct.country) as num_countries
  from country_territories ct
  group by ct.region, ct.subregion
  order by num_countries desc) nc
where nc.num_countries > 10;

-- 9. Return world countries that have a greater population density of the most
-- densely populated african country

-- density = p/km^2
select wc.alpha_3, wc.country, wc.density
from world_countries wc
where wc.density > (
	select max(wc1.density)
	from world_countries wc1
	where wc1.region = 'Africa'
);

-- 10. Return the difference in percentage of emissions of a country between 2010 and 2020

drop view if exists emissions2010;
create view emissions2010 as
select alpha_3, country, total as emissions2010
from co2_emissions
where ref_year = 2010;

select * from emissions2010;

drop view if exists emissions2020;
create view emissions2020 as
select alpha_3, country, total as emissions2020
from co2_emissions
where ref_year = 2020;

select * from emissions2020;

select 
	e10.alpha_3, 
	e10.country,
	wc.region,
	e10.emissions2010, 
	e20.emissions2020,
	round(((e20.emissions2020 - e10.emissions2010) / e10.emissions2010) * 100, 2) as percentage
from emissions2010 e10, emissions2020 e20, world_countries wc
where 
	e10.alpha_3 = wc.alpha_3 and
	e10.alpha_3 = e20.alpha_3 and
	e10.emissions2010 > 0 and
	e20.emissions2020 > 0 -- data missing otherwise
order by percentage desc;

-- 11. Return country population, subregion, and total emissions of the top 10 
--countries of CO2 emissions of coal from 2010 to 2020

select wc.country, wc.population2020, ct.subregion, sum(co2.coal) as total_emissions
from world_countries wc, country_territories ct, co2_emissions co2
where 
	co2.coal is not null and 
	wc.country = ct.country and
	wc.country = co2.country and 
	co2.ref_year between 2010 and 2020
group by wc.country, wc.population2020, ct.subregion  
order by total_emissions desc
limit 10;



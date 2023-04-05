/* ------------------------------ foreign keys ------------------------------ */
alter table world_countries add constraint fk_alpha_3_wc primary key (alpha_3);
alter table country_territories add constraint fk_alpha_3_ct foreign key (alpha_3) references world_countries (alpha_3);
alter table eu_countries
 add constraint fk_alpha_3_eu foreign key (alpha_3) references world_countries (alpha_3);
alter table co2_emissions add constraint fk_alpha_3_co2 foreign key (alpha_3) references world_countries (alpha_3);

/* ----------------------------- world countries ---------------------------- */
alter table world_countries
    add constraint unique_country_wc unique (country);
alter table world_countries     alter column country set not null,
    alter column population2020 set not null,    alter column density set not null,
    alter column land_area set not null,    alter column region set not null;

/* --------------------------- country territories -------------------------- */
alter table country_territories
 add constraint unique_country_ct unique (country), add constraint unique_alpha_2_ct unique (alpha_2);
 alter table country_territories
 alter column country set not null, alter column alpha_2 set not null,
 alter column region set not null, alter column subregion set not null;

/* ------------------------------ eu countries ------------------------------ */
alter table eu_countries
 add constraint unique_country_eu unique (country), add constraint unique_capital_eu unique (capital);
 alter table eu_countries
 alter column country set not null, alter column capital set not null;

/* ------------------------------ co2 emissions ----------------------------- */
alter table co2_emissions
 add constraint unique_country_co2 unique (country, ref_year); 
alter table co2_emissions
 alter column country set not null;
 
/* --------------------------------- indexes -------------------------------- */
/* Index selectivity -> create index on columns that are common in WHERE, -- ORDER BY and GROUP BY clauses. We may consider adding an index in colums 
-- that are used to relate other tables (through a JOIN, for example)-- and on values that have big domains, i.e. names, etc. Don't create indexes 
-- on columns with small variability, like Male/Female columns.*/
create index country_index_wc
on world_countries (country);

create index population_index_wc
on world_countries (population2020);

create index total_emissions_index_co2 
on co2_emissions (total);

/* --------------------------------- queries -------------------------------- */

-- 1. Return the name of country the regions and the medage with medage lower then 30
select country, med_age, region, fert_rate 
from world_countries 
group by country, med_age, region, fert_rate
having med_age < 30 
order by region, med_age;

-- 2. Retun countries and their subregion that are in Europe but not in the
-- European Union
select country, subregion
from country_territories ct
where ct.alpha_3 not in (
	select eu.alpha_3
	from eu_countries eu
)
group by subregion, country, region
having ct.region = 'Europe'
order by subregion;

-- 3. Return all the countries in the european union that are not geographically in europe 

select wc.alpha_3, wc.country, wc.region, eu.join_date, eu.currency
from eu_countries eu, world_countries wc
where 
	eu.alpha_3 = wc.alpha_3 and
	wc.region != 'Europe';

-- 4. For the top 10 populated countries return country, population, land area and density 

--density = p/km^2
--land area = km^2

select
        country,
        to_char(population2020, 'FM999G999G999G999') as population2020,
        to_char(land_area, 'FM999G999G999G999') as land_area,
        density
from world_countries wc
order by wc.population2020 desc
limit 10;

-- 5. for every region return the average of population for region 
-- and the most populated country

-- Med 10 exe 109,5
drop materialized view if exists most_populated_country;

create materialized view most_populated_country as
select wc.country, wc.population2020, wc.region
from world_countries wc
inner join (
	select  max(population2020) as maxp, region
	from world_countries
	group by region
) wc1 on wc.region = wc1.region and wc.population2020 = wc1.maxp;

drop materialized view if exists avg_population;

create materialized view avg_population as
select wc.region, avg(wc.population2020), sum(wc.population2020)
from world_countries wc
group by wc.region;

select 
	avgp.region, 
	to_char(round(avgp.avg, 2), 'FM999G999G999D99') as average_Population,
	to_char(round(avgp.sum, 2), 'FM999G999G999G999') as sum_Population, 
	mpc.country, 
	to_char(mpc.population2020, 'FM999G999G999G999') as population
from avg_population avgp, most_populated_country mpc 
where avgp.region = mpc.region;

-- 6. Return world countries that have a greater population density of the most
-- densely populated african country

-- density = p/km^2

select wc.alpha_3, wc.country, wc.density
from world_countries wc
where wc.density > (
	select max(wc1.density)
	from world_countries wc1
	where wc1.region = 'Africa')
order by wc.density desc;

-- 7. Return the country polulation and subregion of every country such that the total amount of
-- Coal co2Emission from 2010 t0 2020 is less than 100;

-- co2 emissions are measured in million metric tons (MMT)

select wc.country, wc.population2020, sum(co2.coal) as total_emissions
from world_countries wc, co2_emissions co2
where
	co2.coal is not null and
	wc.alpha_3 = co2.alpha_3 and 
	co2.ref_year between 2010 and 2020 
group by wc.country, wc.population2020
having sum(co2.coal) < 100
order by total_emissions_MMT desc;

-- 8. Return country population, and total emissions of the top 10 
--countries of CO2 emissions of coal from 2010 to 2020

select wc.country, wc.population2020, sum(co2.coal) as total_emissions, wc.region
from world_countries wc, co2_emissions co2
where 
	co2.coal is not null and 
	wc.alpha_3 = co2.alpha_3 and 
	co2.ref_year between 2010 and 2020
group by wc.country, wc.population2020  
order by total_emissions desc
limit 10;

-- 9. Return the difference in percentage of emissions of a country between 2010 and 2020

drop materialized view if exists emissions2010;
create materialized view emissions2010 as
select alpha_3, country, total as emissions2010
from co2_emissions
where ref_year = 2010;
select * from emissions2010;

drop materialized view if exists emissions2020;
create materialized view emissions2020 as
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
	e20.emissions2020 > 0
order by percentage;




-- 10. Return the maximum emission, the year and the region for each country

select co2.country, max(co2.total), co2.ref_year, ct.region
from co2_emissions co2, country_territories ct
where co2.alpha_3 = ct.alpha_3
group by co2.country, co2.ref_year, ct.region

select co2_1.country, co2_1.total, co2_1.ref_year
from co2_emissions co2_1
left join co2_emissions co2_2
on co2_1.total < co2_2.total

select distinct country from co2_emissions
where alpha_3 is null

select wc.country, wc.alpha_3 from world_countries wc
where wc.alpha_3 not in (select distinct alpha from co2_emissions)

select distinct country, alpha_3 from co2_emissions
where alpha_3 not in (select wc.alpha_3 from world_countries wc)

-- 11. Return region and subregion with the number of countries > threshold

drop view if exists num_countries_for_subregion;
create view num_countries_for_subregion as
select ct.region, ct.subregion, count(ct.country) as num_countries
from country_territories ct
group by ct.region, ct.subregion
order by num_countries desc;

select *
from num_countries_for_subregion
where num_countries > 10;

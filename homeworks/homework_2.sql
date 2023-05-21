
alter table world_countries 
	add constraint pk_alpha_3_wc primary key (alpha_3);
	
alter table country_territories
	add constraint pk_alpha_3_ct primary key (alpha_3);
	
alter table eu_countries 
	add constraint pk_alpha_3_eu primary key (alpha_3);
	
alter table co2_emissions 
	add constraint pk_alpha_3_co2 primary key (alpha_3, ref_year);
	
/* ------------------------------ foreign keys ------------------------------ */

alter table country_territories 
	add constraint fk_alpha_3_ct foreign key (alpha_3) references world_countries (alpha_3);

alter table eu_countries
	add constraint fk_alpha_3_eu foreign key (alpha_3) references world_countries (alpha_3);

alter table co2_emissions 
	add constraint fk_alpha_3_co2 foreign key (alpha_3) references world_countries (alpha_3);

/* ----------------------------- world countries ---------------------------- */
alter table world_countries
    add constraint unique_country_wc unique (country);

alter table world_countries     
	alter column country set not null,
    alter column population2020 set not null,    
	alter column density set not null,
    alter column land_area set not null,    
	alter column region set not null;

/* --------------------------- country territories -------------------------- */
alter table country_territories
 add constraint unique_country_ct unique (country), 
 add constraint unique_alpha_2_ct unique (alpha_2);

alter table country_territories
	alter column country set not null, 
	alter column alpha_2 set not null,
	alter column region set not null, 
	alter column subregion set not null;

/* ------------------------------ eu countries ------------------------------ */
alter table eu_countries
	add constraint unique_country_eu unique (country), 
	add constraint unique_capital_eu unique (capital);

alter table eu_countries
	alter column country set not null, 
	alter column capital set not null;

/* ------------------------------ co2 emissions ----------------------------- */
alter table co2_emissions
	add constraint unique_country_co2 unique (country, ref_year); 

alter table co2_emissions
	alter column country set not null;
 
/* --------------------------------- indexes -------------------------------- */
/* Index selectivity -> create index on columns that are common in WHERE, 
-- ORDER BY and GROUP BY clauses. We may consider adding an index in colums 
-- that are used to relate other tables (through a JOIN, for example)
-- and on values that have big domains, i.e. names, etc. Don't create indexes 
-- on columns with small variability, like Male/Female columns.
*/
create index country_index_wc
on world_countries (country);

create index population_index_wc
on world_countries (population2020);

create index total_emissions_index_co2 
on co2_emissions (total);

/* --------------------------------- queries -------------------------------- */

-- 5. for every region return the average of population for region 
-- and the most populated country

drop materialized view if exists most_populated_country;

-- returns the most populated counry for each region
create materialized view most_populated_country as
select wc.country, wc.population2020, wc.region
from world_countries wc
inner join (
	select  max(population2020) as maxp, region
	from world_countries
	group by region
) wc1 on wc.region = wc1.region and wc.population2020 = wc1.maxp;

drop materialized view if exists avg_population;

-- returns the average and the total population for each region
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


-- 7. Return the country polulation and subregion of every country such that the total amount of
-- Coal co2Emission from 2010 t0 2020 is less than 100;
-- 
-- 8. Return country population and total emissions of the top 10 
--countries of CO2 emissions of coal from 2010 to 2020

-- for each country, return the population and the total coal-related emissions from 2010 to 2020

drop materialized view if exists total_emissions_1020;

create materialized view total_emissions_1020 as
select wc.country, wc.population2020, sum(co2.coal) as total_emissions
from world_countries wc, co2_emissions co2
where
	co2.coal is not null and
	wc.alpha_3 = co2.alpha_3 and 
	co2.ref_year between 2010 and 2020 
group by wc.country, wc.population2020;

-- 8.

select * 
from total_emissions_1020
order by total_emissions desc
limit 10;

-- 7.

select * 
from total_emissions_1020
where total_emissions < 100
order by total_emissions desc;

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

drop materialized view if exists maximum_for_country;

create materialized view maximum_for_country as
select alpha_3, max(total) as total
from co2_emissions co2
group by alpha_3;

select distinct co2.alpha_3, co2.country, max(co2.ref_year), mfc.total, wc.region
from 
	co2_emissions co2,
	maximum_for_country mfc,
	world_countries wc
where 
	co2.total = mfc.total and 
	co2.alpha_3 = mfc.alpha_3 and
	co2.alpha_3 = wc.alpha_3
group by co2.alpha_3, co2.country, mfc.total, wc.region
order by mfc.total desc;



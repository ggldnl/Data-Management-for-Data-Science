
/* ------------------------------ foreign keys ------------------------------ */

/*
Using a foreign key as an integrity constraint in a database can improve 
performance in some cases, but it depends on the specific situation and the 
queries being run. A foreign key constraint can help ensure referential integrity 
by preventing the creation of orphaned records, which are records that reference 
non-existent records in another table. By enforcing this constraint, the database 
can avoid costly operations such as cascading deletes or updates. Additionally, 
a foreign key constraint can sometimes improve performance by allowing the 
database to use indexing more efficiently. When a foreign key constraint is 
created, an index is automatically created on the foreign key column(s). This 
index can speed up joins and other queries that involve the foreign key column(s).
However, there are also cases where foreign key constraints can actually decrease 
performance. For example, if a large number of tables have foreign keys referencing 
a single table, it can lead to a high overhead for inserts, updates, and deletes 
in that referenced table. In these cases, it may be necessary to carefully consider 
the tradeoffs between referential integrity and performance.
*/

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



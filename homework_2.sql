
/* ------------------------------ foreign keys ------------------------------ */

alter table country_territories
	add constraint fk_alpha_3_ct foreign key (alpha_3) references world_countries (alpha_3)

alter table eu_countries
	add constraint fk_alpha_3_eu foreign key (alpha_3) references world_countries (alpha_3)

alter table co2_emissions
	add constraint fk_alpha_3_co2 foreign key (alpha_3) references world_countries (alpha_3)

/* --------------------- unique and not null constraints -------------------- */

alter table world_countries
    add constraint country_unique unique (country)

alter table world_countries alter column population set not null;

/* --------------------------------- queries -------------------------------- */


Goodmorning, today we talk about our database on world population and pollution.

The database in formed by 4 relation:

- World Countries in which consist on data for each country such as population, land area, density and soo on;

- Country territories has the geographically position for each country in region, subregion and intermadiate region

- Eu coutries is formed by countries that are in the european union and their capital, gpt value and year of ammission

- The last one is Co2 Emissions that keep the emission of co2 from 1750 to 2021 for each country. The emission are divided for kind such as
carbon, oil, ect..

This first schema will be improved applying primary key, foreign key and constraint to have a consistent database.

We have implemented 10 queries on the database to see some difference and curiosity on the world countries

1. Return the name of country and the medage with medage lower then 30:
  This query give us a significant result on the population of african countries that are the youngest ones.
  We add also the fert_rate and we can see how it improves the medage.

2. Retun countries and their subregion that are in Europe but not in the European Union:
  Here we can see all the european countries that are not in the EU
  As we can see the countries are 22. This is ambiguos because if we sum these countries 
  with the 27 countries in the UE we can suppose that there are 49 european countries, but
  our database says that there are 48 ueropean countries.

So, is there a country in the UE but not in europe?
3. Return all the countries in the european union that are not geographically in europe:
  The answer is yes and we can see that Cypro which is an asian country joined in 2004 and has also the Euro as currency


4. For the top 10 populated countries return country, population, land area and density:
  First one is China with a huge number of population and the second one is India which has a big difference
  in measure of land area and density. The Russia, which is the biggest country but has a small area populated.

5. for every region return the average of population for region and the most populated country:
  As we have seen before the most populated country is china and also his region Asia is the one with higher population avg

6. Return world countries that have a greater population density of  the most densely populated african country.
  We choose Aftica as regions because the most densely populated country is Monaco, in Europe, and african countries have a relatively low population density

7. Return the country polulation and subregion of every country such that the total amount of coal co2Emission from 2010 t0 2020 is less than 100. 
A lot of countries between 2010 and 2020 was carbon neutral because, as we can see, the total emissions was 0.

8. Return country population, subregion, and total emissions of the top 10  countries of CO2 emissions of coal from 2010 to 2020.
We can see how about half of them are asian counries. The worst of them is China. 

DA FARE INSIEME 7 E 8 ^

9. Return the difference in percentage of emissions of a country between 2010 and 2020. we can see that Italy is in 16th place and has reduced emissions by 30%.

10. 

. Return the country polulation and subregion of every country such that the total amount of
   Coal co2Emission from 2010 t0 2020 is less than 100

. Return region and subregion with the number of countries > 10


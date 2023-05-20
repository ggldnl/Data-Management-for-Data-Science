
// import json file for each collection
// mongoimport --uri mongodb+srv://pasqualealiperta:pasqualo97@cluster0.zk2ly31.mongodb.net/World_population_and_emissions --collection world_countries --jsonArray --file /home/pasquale/Desktop/DataManagement/world_countries.json
// mongoimport --uri mongodb+srv://pasqualealiperta:pasqualo97@cluster0.zk2ly31.mongodb.net/World_population_and_emissions --collection co2_emissions --jsonArray --file /home/pasquale/Desktop/DataManagement/co2_emissions.json
// mongoimport --uri mongodb+srv://pasqualealiperta:pasqualo97@cluster0.zk2ly31.mongodb.net/World_population_and_emissions --collection country_territories --jsonArray --file /home/pasquale/Desktop/DataManagement/country_territories.json
// mongoimport --uri mongodb+srv://pasqualealiperta:pasqualo97@cluster0.zk2ly31.mongodb.net/World_population_and_emissions --collection eu_countries --jsonArray --file /home/pasquale/Desktop/DataManagement/eu_countries.json

// select the db
// use world_population_and_emissions

/*
    1. Return the name of country the regions and the medage with medage lower than 30

    select country, med_age, region, fert_rate 
    from world_countries 
    group by country, med_age, region, fert_rate
    having med_age < 30 
    order by region, med_age; -- the higher the fertility rate, the lower the average age
*/

db.world_countries.find(
    {med_age: {$lt: 30}}, {country: 1, med_age: 1, regions: 1, fertility_rate: 1}
).sort({country: 1, med_age: 1, country: 1}) 


/*
    2. Return countries and their subregion that are in Europe but not 
    in the European Union
*/
db.country_territories.aggregate([
    {
        $match: {region: 'Europe'}
    }, 
    {
        $lookup: {
            from: "eu_countries",
            localField: "_id",
            foreignField: "_id",
            as: "eu_countries"
        }
    },
    {
        $match: {
            eu_countries: { $size: 0 }
        }
    },
    {
        $project: {
            _id: 0,
            country: 1,
            subregion: 1
        }
    }, {
        $sort: {subregion: 1}
    }
])

/*
    3. Return all the countries in the european union that are not geographically 
    in europe 
*/
db.eu_countries.aggregate([
    {
        $match: {region: 'Europe'}
    }, 
    {
        $lookup: {
            from: "eu_countries",
            localField: "_id",
            foreignField: "_id",
            as: "eu_countries"
        }
    },
    {
        $match: {
            eu_countries: { $size: 0 }
        }
    },
    {
        $project: {
            _id: 0,
            country: 1,
            subregion: 1
        }
    }, {
        $sort: {subregion: 1}
    }
])

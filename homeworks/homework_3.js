// 1. Return the name of country the regions and the medage with medage lower then 30

let res = db.world_countries.find(
    { med_age: { $lt: 30 } }, { country: 1, med_age: 1, region: 1, fertility_rate: 1 }
).sort({ region: 1, med_age: 1, country: 1 })


// 2. Return countries and their subregion that are in Europe but not in the European Union
// All the countries that are in Europe but not in the European Union -> 22

db.country_territories.aggregate([
    {
        $match: {
            region: "Europe"
        }
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
            subregion: 1,
            country: 1

        }
    },
    // does not order automatically by country value 
    // so we have to add it manually
    { $sort: { subregion: 1, country: 1 } }
])

// 3. Return all the countries in the european union that are not geographically in europe

db.eu_countries.aggregate([
    {
        $lookup: {
            from: "world_countries",
            localField: "_id",
            foreignField: "_id",
            as: "world_countries"
        }
    },
    {
        $match: {
            "world_countries.region": { $ne: "Europe" }
        }
    },
    {
        // If you want to extract a specific field for every element
        // of the array resulting from the $lookup stage, you can use
        // the $unwind stage in MongoDB aggregation. The $unwind
        // stage deconstructs an array field and generates a new document
        // for each element in the array.
        $unwind: "$world_countries"
    },
    {
        $project: { //
            _id: 0,
            country: 1,
            region: "$world_countries.region",
            join_date: 1,
            currency: 1,
        }
    }
])

// 4. For the top 10 populated countries return country, population, land area and density

// density = p/km^2
// land area = km^2

db.world_countries.find(
    { land_area: { $gt: 0 } },
    {
        country: 1,
        population_2020: 1,
        land_area: 1,
        density: 1,
    }
).sort(
    { population_2020: -1 }
).limit(10)

// using aggregation to compute density
db.world_countries.aggregate([
    { $sort: { population_2020: -1 } },
    { $limit: 10 },
    {
        $project: {
            _id: 0,
            country: 1,
            population_2020: 1,
            land_area: 1,
            density: 1,
            computed_density: { $divide: ["$population_2020", "$land_area"] }
        }
    }
])

// 5. for every region return the average of population for region
//  and the most populated country. (un-optimized version)

db.world_countries.aggregate([
    {
        $group: {
            _id: "$region",
            avg_population: { $avg: "$population_2020" },
            total_population: { $sum: "$population_2020" },
            max_population: { $max: "$population_2020" },
        }
    },
    {
        $lookup: {
            from: "world_countries",
            localField: "max_population",
            foreignField: "population_2020",
            as: "most_populated_country"
        }
    },
    {
        $project: {
            _id: 0,
            region: "$_id",
            avg_population: 1,
            total_population: 1,
            max_population: 1,
            country: { $arrayElemAt: ["$most_populated_country.country", 0] }
        }
    }
])

// alternatively

db.world_countries.aggregate([
    { $sort: { population_2020: -1 } },
    {
        $group: {
            _id: "$region",
            max_population: { $max: "$population_2020" },
            avg_population: { $avg: "$population_2020" },
            sum_population: { $sum: "$population_2020" },
            document: { $first: "$$ROOT" }
        }
    },
    {
        $project: {
            _id: 0,
            region: "$_id",
            avg_population: 1,
            sum_population: 1,
            country: "$document.country",
            max_population: 1
        }
    }
])

// 6. Return world countries that have a greater population density of the most
// densely populated African country.

// density = p/km^2

db.world_countries.aggregate([
    {
        $match: {
            region: "Africa"
        }
    },
    {
        $sort: {
            density: -1
        }
    },
    {
        $limit: 1
    },
    {
        $lookup: {
            from: "world_countries",
            let: { maxDensity: "$density" },
            pipeline: [
                {
                    $match: {
                        $expr: { $gt: ["$density", "$$maxDensity"] }
                    }
                },
                {
                    $project: {
                        _id: 1,
                        country: 1,
                        density: 1
                    }
                },
                {
                    $sort: {
                        density: -1
                    }
                }
            ],
            as: "countries"
        }
    },
    {
        $unwind: "$countries"
    },
    {
        $project: {
            _id: 0,
            _id: "$countries._id",
            country: "$countries.country",
            density: "$countries.density"
        }
    }
])

// alternatively

db.world_countries.aggregate([
    {
        $group: {
            _id: "$region", max_density: { $max: "$density" },
        }
    },
    {
        $match: {
            _id: "Africa"
        }
    },
    {
        $lookup: {
            from: "world_countries",
            pipeline: [{ $match: {} }],
            as: "country"
        }
    },
    {
        $unwind: "$country"
    },
    {
        $match: {
            $expr: { $gt: ['$country.density', '$max_density'] }
        }
    },
    {
        $project: {
            _id: 1,
            country: "$country.country",
            density: "$country.density"
        }
    }, {
        $sort: {
            density: -1
        }
    }
])

// 7. Return the country population of every country such that the total amount of
// coal emissions from 2010 to 2020 is less than 100. (un-optimized version)

// co2 emissions are measured in million metric tons (MMT)

db.co2_emissions.aggregate([
    // filter out data outside the range [2010, 2020]
    // we don't need that
    {
        $match: {
            "_id.ref_year": { $gte: 2010, $lte: 2020 }
        }
    },
    // group by country such that we have all the years for that country
    // sum the emissions
    {
        $group: {
            _id: "$_id.alpha_3",
            total_coal_emissions: { $sum: "$coal" }
        }
    },
    {
        $match: {
            "total_coal_emissions": { $gt: 0, $lt: 100 }
        }
    },
    // take info about the country
    {
        $lookup: {
            from: "world_countries",
            localField: "_id",
            foreignField: "_id",
            as: "country"
        }
    },
    {
        $unwind: "$country"
    }, {
        $project: {
            _id: 0,
            country: "$country.country",
            population: "$country.population_2020",
            total_coal_emissions: 1
        }
    }, {
        $sort: {
            total_coal_emissions: -1
        }
    }
])

// 8. Return country population and total emissions of the top 10
// countries of CO2 emissions of coal from 2010 to 2020.

db.co2_emissions.aggregate([
    {
        $match: {
            "_id.ref_year": { $gte: 2010, $lte: 2020 }
        }
    },
    {
        $group: {
            _id: "$_id.alpha_3",
            total_coal_emissions: { $sum: "$coal" }
        }
    },
    {
        $lookup: {
            from: "world_countries",
            localField: "_id",
            foreignField: "_id",
            as: "country"
        }
    },
    {
        $unwind: "$country"
    }, {
        $project: {
            _id: 0,
            country: "$country.country",
            population: "$country.population_2020",
            total_coal_emissions: 1,
            region: "$country.region"
        }
    }, {
        $sort: {
            total_coal_emissions: -1
        }
    }, {
        $limit: 10
    }
])

// 9. Return the difference in percentage of emissions of a country between 2010 and 2020

db.co2_emissions.aggregate([
    {
        $lookup: {
            from: "co2_emissions",
            localField: "_id.alpha_3",
            foreignField: "_id.alpha_3",
            as: "doc_2020"
        }
    },
    {
        $unwind: "$doc_2020"
    },
    {
        $match: {
            "_id.ref_year": { $eq: 2010 },
            "doc_2020._id.ref_year": { $eq: 2020 }
        }
    },
    {
        $lookup: {
            from: "world_countries",
            localField: "_id.alpha_3",
            foreignField: "_id",
            as: "country_info"
        }
    },
    {
        $unwind: "$country_info"
    },
    {
        $match: {
            "total": { $gt: 0 },
            "doc_2020.total": { $gt: 0 }
        }
    },
    {
        $project: {
            _id: 0,
            alpha_3: "$country_info._id",
            country: "$country",
            region: "$country_info.region",
            emissions2010: "$total",
            emissions2020: "$doc_2020.total",
            percentage: { $multiply: [{ $divide: [{ $subtract: ["$doc_2020.total", "$total"] }, "$total"] }, 100] }
        }
    },
    {
        $sort: {
            percentage: 1
        }
    }
])

// 10. Return the maximum emission, the year and the region for each country. (un-optimized version)

db.co2_emissions.aggregate([
    { $sort: { total: -1 } },
    {
        $group: {
            _id: "$_id.alpha_3",
            max_emissions: { $max: "$total" },
            document: { $first: "$$ROOT" }
        }
    },
    {
        $lookup: {
            from: "world_countries",
            localField: "_id",
            foreignField: "_id",
            as: "country_info"
        }
    },
    {
        $unwind: "$country_info"
    },
    {
        $project: {
            alpha_3: "$_id.alpha_3",
            country: "$country_info.country",
            ref_year: "$document._id.ref_year",
            total: "$max_emissions",
            region: "$country_info.region"
        }
    },
    {
        $sort: {
            ref_year: -1,
            country: 1
        }
    }
])

 // res.forEach(printjson);

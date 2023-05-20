const { MongoClient } = require('mongodb');
const fs = require('fs');

async function insertData(client_name, db_name, collection_name, file_path) {

    // e.g. 
    // client_name = 'mongodb://localhost:27017'
    // db_name = 'test'
    // collection_name = 'world_countries'
    // file_path = '/home/daniel/Git/DMDS/datasets/original_json/world_countries.json'

    try {
        const client = new MongoClient(client_name);

        await client.connect();
        const database = client.db(db_name); // Replace with your database name
        const collection = database.collection(collection_name); // Replace with your collection name

        const jsonData = JSON.parse(fs.readFileSync(file_path)); // Update the path to your JSON file

        const result = await collection.insertMany(jsonData);
        console.log(`${result.insertedCount} documents inserted successfully.`);
    } catch (error) {
        console.error('Error inserting data:', error);
    } finally {
        // await client.close(); // Close the MongoDB connection
    }
}

// insertData();

const client = 'mongodb://localhost:27017/'
const db_name = 'test'
const collection = 'world_countries'
const file_path = '/home/daniel/Git/DMDS/datasets/original_json/world_countries.json'
insertData(client, db_name, collection, file_path)

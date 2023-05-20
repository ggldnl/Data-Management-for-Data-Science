import json
import pymongo 
import argparse


def insert_json(client_name, db_name, collection_name, file_path):
    """
    Inserts the content of the file into the specified collection of the db 
    Sample usage: insert_json("mongodb://127.0.0.1:27017/", "people", "person", "test.json")
    """

    # Creating the connection
    client = pymongo.MongoClient(client_name)

    # database
    db = client[db_name]
    
    # Created or Switched to collection 

    collection = db[collection_name]
    
    # Loading or Opening the json file
    with open(file_path) as file:
        file_data = json.load(file)
        
    # Inserting the loaded data in the Collection
    # if JSON contains data more than one entry
    # insert_many is used else inser_one is used
    if isinstance(file_data, list):
        collection.insert_many(file_data)  
    else:
        collection.insert_one(file_data)


if __name__ == '__main__':

    parser = argparse.ArgumentParser(
                    prog='ProgramName',
                    #description='What the program does',
                    #epilog='Text at the bottom of help'
                    )

    parser.add_argument('-c', '--client', required=True)
    parser.add_argument('-db', '--db_name', required=True)
    parser.add_argument('-col', '--collection_name', required=True)
    parser.add_argument('-f', '--file', required=True)

    args = parser.parse_args()
    insert_json(args.client, args.db_name, args.collection_name, args.file)

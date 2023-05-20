from insert_json import insert_json
from pathlib import Path
import argparse
import os


def get_local_folder():
    """
    Returns the PurePath of the project folder
    """

    try:
        return Path(os.path.dirname(os.path.realpath(__file__))) # py
    except NameError:
        pass
    return os.path.abspath("") # ipynb

if __name__ == '__main__':

    #client = 'mongodb://127.0.0.1:27017/'
    client = 'mongodb://localhost:27017/'
    
    #db_name = 'world_countries_and_emissions'
    db_name = 'test'
    
    collections = ['co2_emissions', 'country_territories', 'eu_countries', 'world_countries']
    
    
    current_folder = get_local_folder()
    project_folder = current_folder.parent
    base_path = Path(project_folder, 'datasets/original_json')

    # suppose the dataset files have the same name of the respective collection in the db
    files = []
    for collection in collections:
        file_path = Path(base_path, collection + '.json')
        insert_json(client, db_name, collection, file_path)

import itertools
import csv
import tqdm
import random

# -------------------------- co2_emissions_augmented ------------------------- #

# country,alpha_3,refyear,total,coal,oil,gas,cement,flaring,other,percapita
schema = {
    'country': 'string',
    'alpha_3': 'string', 
    'ref_year': 'numeric', 
    'total': 'numeric', 
    'coal': 'numeric', 
    'oil': 'numeric', 
    'gas': 'numeric', 
    'cement': 'numeric', 
    'flaring': 'numeric', 
    'other': 'numeric', 
    'per_capita': 'numeric'
}
header = ['country', 'alpha_3', 'ref_year', 'total', 'coal', 'oil', 'gas', 'cement', 'flaring', 'other', 'per_capita']
keys = ['alpha_3', 'ref_year']

output_file = 'co2_emissions_augmented.csv'

# ------------------------------ world_countries ----------------------------- #

# alpha_3,country,population_2020,yearly_change,net_change,density,land_area,migrants,fertility_rate,med_age,urban,world_share,region
#schema = {
#    'country': 'string',
#    'alpha_3': 'string', 
#    'population2020': 'numeric',
#    'yearly_change': 'numeric',
#    'net_change': 'numeric',
#    'density': 'numeric',
#    'land_area': 'numeric',
#    'migrants': 'numeric',
#    'fertility_rate': 'numeric',
#    'med_age': 'numeric',
#    'urban': 'numeric',
#    'world_share': 'numeric',
#    'region': 'numeric'
#}
#header = ['alpha_3','country','population2020','yearly_change','net_change','density','land_area','migrants','fertility_rate','med_age','urban','world_share','region']
#keys = ['alpha_3']
#
#output_file = 'world_countries_augmented.csv'

# ---------------------------- country_territories --------------------------- #

# country,alpha_2,alpha_3,region,subregion,intermediate_region
#schema = {
#    'country': 'string',
#    'alpha_2': 'string',
#    'alpha_3': 'string', 
#    'region' : 'string',
#    'subregion': 'string',
#    'intermediate_region': 'string'
#}
#header = ['country', 'alpha_2', 'alpha_3', 'region', 'subregion', 'intermediate_region']
#keys = ['alpha_3']
#
#output_file = 'country_territories_augmented.csv'

# --------------------------------- functions -------------------------------- #

def generate_numeric ():
    return str(random.randint(10, 10000))

def generate_string (length = 10):
    return ''.join([chr(random.randint(97, 122)) for _ in range(length)])

def generate_numeric_key ():
    return [str(i) for i in range(1970, 2022)]

def generate_string_key (length = 3):

    # define the list of letters
    letters = [chr(i) for i in range(65, 91)]

    # generate all possible combinations of 3 letters using itertools
    #combinations = itertools.combinations(letters, length)
    combinations = [p for p in itertools.product(letters, repeat=length)]
    combinations_str = []
    for c in combinations:
        combinations_str.append(''.join(c))
    return combinations_str


# -------------------------- don't touch from now on ------------------------- #

print('Generating dataset {}'.format(output_file))

key_combinations = [generate_string_key() if schema[c] == 'string' else generate_numeric_key() for c in keys]
permutations = list(itertools.product(*key_combinations))

# take the indexes
key_idx = []
for elem in keys:
    idx = header.index(elem)
    key_idx.append(idx)

# open the file in the write mode
with open(output_file, 'w') as f:

    writer = csv.writer(f)

    # write the header to the csv file
    writer.writerow(header)

    # loop over the keys
    for key in tqdm.tqdm(permutations):

        # generate the row
        row_string = [''] * len(header)

        # set the keys
        for i, idx in enumerate(key_idx):
            row_string[idx] = key[i]

        for i, col in enumerate(header): # for each column

            # skip if this is a key, we already set it in that case
            if col in keys:
                continue
        
            row_string[i] = generate_numeric() if schema[col] == 'numeric' else generate_string()

        writer.writerow(row_string)
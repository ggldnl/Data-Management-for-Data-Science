from countryinfo import CountryInfo
import csv

# ----------------------------------- data ----------------------------------- #

rows = [['AT', 'Austria', 'Vienna', 455.32, '1995-01-01', 'Euro'],
['BE', 'Belgium', 'Brussels', 530.76, '1952-01-01', 'Euro'],
['BG', 'Bulgaria', 'Sofia', 64.11, '2007-01-01', 'Bulgarian Lev'],
['CY', 'Cyprus', 'Nicosia', 24.75, '2004-05-01', 'Euro'],
['CZ', 'Czech Republic', 'Prague', 244.88, '2004-05-01', 'Czech Koruna'],
['DE', 'Germany', 'Berlin',  3693.20, '1952-01-01', 'Euro'],
['DK', 'Denmark', 'Copenhagen', 306.73, '1973-01-01', 'Danish Krone'],
['EE', 'Estonia', 'Tallinn', 27.37, '2004-05-01', 'Euro'],
['FI', 'Finland', 'Helsinki', 236.72, '1995-01-01', 'Euro'],
['FR', 'France', 'Paris', 2582.49, '1952-01-01', 'Euro'],
['GR', 'Greece', 'Athens', 209.85, '1981-01-01', 'Euro'],
['HR', 'Croatia', 'Zagreb', 60.08, '2013-07-01', 'Croatian Kuna'],
['HU', 'Hungary', 'Budapest', 155.84, '2004-05-01', 'Hungarian Forint'],
['IE', 'Ireland', 'Dublin', 383.49, '1973-01-01', 'Euro'],
['IT', 'Italy', 'Rome', 1937.25, '1952-01-01', 'Euro'],
['LT', 'Lithuania', 'Vilnius', 54.15, '2004-05-01', 'Euro'],
['LU', 'Luxembourg', 'Luxembourg City', 70.36, '1952-01-01', 'Euro'],
['LV', 'Latvia', 'Riga', 30.24, '2004-05-01', 'Euro'],
['MT', 'Malta', 'Valletta', 16.80, '2004-05-01', 'Euro'],
['NL', 'Netherlands', 'Amsterdam', 902.36, '1952-01-01', 'Euro'],
['PL', 'Poland', 'Warsaw', 595.9, '2004-05-01', 'Polish złoty'],
['PT', 'Portugal', 'Lisbon', 218.8, '1986-01-01', 'Euro'],
['RO', 'Romania', 'Bucharest', 239.7, '2007-01-01', 'Romanian leu'],
['SK', 'Slovakia', 'Bratislava', 104.2, '2004-05-01', 'Euro'],
['SI', 'Slovenia', 'Ljubljana', 54.6, '2004-05-01', 'Euro'],
['ES', 'Spain', 'Madrid', 1396.0, '1986-01-01', 'Euro'],
['SE', 'Sweden', 'Stockholm', 538.4, '1995-01-01', 'Swedish krona']]

alpha = 'alpha3' # 'alpha2'/'alpha3'
header = True

# ---------------------------------- script ---------------------------------- #

if alpha == 'alpha3':
    # use alpha3 instead of alpha2
    for row in rows:
        name = row[1]
        country = CountryInfo(name)
        info = country.info()
        alpha3 = info['ISO']['alpha3']
        row[0] = alpha3

# opening the csv file in 'w+' mode
csv_path = 'eu_countries_{}.csv'.format(alpha) 
file = open(csv_path, 'w+', newline ='')
 
if header:
    header = [alpha, 'country', 'capital', 'join_date', 'currency']
    rows.insert(0, header)

# writing the data into the file
with file:   
    write = csv.writer(file)
    write.writerows(rows)

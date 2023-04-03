import csv
import pyperclip

csv_path = '/tmp/world_countries.csv' # should have the header
table_name = 'world_countries'

rows = []
with open(csv_path, 'r') as file:
	csvreader = csv.reader(file)
	header = next(csvreader)
	for row in csvreader:
		rows.append(row)

# insert into world_countries (...) values (...), (...), ...
str_db = 'insert into {} ({}) values'.format(table_name, ','.join(header))

for i, row in enumerate(rows):
	row_formatted = ['\"{}\"'.format(elem) if not elem.replace('.','',1).isdigit() else elem for elem in row]
	str_db += '({})'.format(','.join(row_formatted))
	if i < len(rows) - 1:
		str_db += ',\n'
	else:
		str_db += ';'


pyperclip.copy(str_db)
print(str_db)
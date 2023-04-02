import csv

input_csv_path = 'country_territories.csv'
output_csv_path = 'country_territories_formatted.csv'
rows = []

# 0    1       2       3            4          5      6          7                   8           9               10                       
# name,alpha-2,alpha-3,country-code,iso_3166-2,region,sub-region,intermediate-region,region-code,sub-region-code,intermediate-region-code
with open(input_csv_path, 'r') as in_file:
	csvreader = csv.reader(in_file)
	header = next(csvreader)
	for row in csvreader:
		del row[3] # country-code
		del row[3] # iso_3166-2
		del row[6] # region-code
		del row[6] # sub-region-code
		del row[6] # intermediate-region-code
		rows.append(row)

with open(output_csv_path, 'w') as out_file:
	write = csv.writer(out_file)
	write.writerows(rows)

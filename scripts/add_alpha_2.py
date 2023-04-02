import csv

csv_path = 'all.csv'

rows = []
with open(csv_path, 'r') as file:
	csvreader = csv.reader(file)
	header = next(csvreader)
	for row in csvreader:
		rows.append(row)

print(header)
print(rows)
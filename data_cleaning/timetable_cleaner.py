# Author Conor O'Kelly

### Aim of this script will be to open the csv file and read in the csv data.
### This data is then cleaned and returned as a json object

import unittest, csv, json, re



with open("1.test_data/B0.02 B0.03 B0.04 Timetable.csv", "r") as csv_file:
    file_ouput = csv.reader(csv_file)

    # Sort through the rows of the file
    # First row contains meta information about dates

    ### First build a picture of the data contained. i.e => number of week present / if each week has 5 days / dates

    print(file_ouput)
    for row in file_ouput:
        print(row)

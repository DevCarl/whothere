# Author Conor O'Kelly

### Aim of this script will be to open the csv file and read in the csv data.
### This data is then cleaned and returned as a json object

import unittest, csv, json, re


def convert_csv_to_array(directory):

    try:
        with open(directory, "r") as csv_file:
            file_ouput = csv.reader(csv_file)

            # Turn csv object into 3D array
            csv_rows = []
            for current_row in file_ouput:
                csv_rows.append(current_row)

            print(csv_rows[0])


    except FileNotFoundError:
        csv_rows = []
        print("File not found")

    return csv_rows

def sort_csv_output_return_json(csv_array):

    # Sort through the rows of the file
    # First row contains meta information about dates

    ### First build a picture of the data contained. i.e => number of week present / if each week has 5 days / dates

    return 0

# def test_that_multidimensional_array_returned:

if __name__ == '__main__':
    convert_csv_to_array("1.test_data/B0.02 B0.03 B0.04 Timetable.csv")

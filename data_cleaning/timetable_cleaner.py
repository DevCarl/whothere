# Author Conor O'Kelly

# Aim of this script will be to open the csv file and read in the csv data.
##This data is then cleaned and returned as a json object

import unittest, csv, json, re, openpyxl


def main(directory):

    sheet_object = load_workbook_return_sheets_object(directory)
    unmerge_excel_cells_and_perserve_data(sheet_object)


def load_workbook_return_sheets_object(directory):

    # Load workbook with all sheets
    work_book = openpyxl.load_workbook(directory)

    # Load a all sheets from workbook
    sheet_names = work_book.get_sheet_names()

    # Remove last sheet name if name == All
    if sheet_names[-1] == "All" or sheet_names[-1] == "all":
        sheet_names.pop(-1)

    # Load sheet object into array
    sheet_objects = []
    for sh_name in sheet_names:
        sheet_objects.append(work_book.get_sheet_by_name(sh_name))

    return sheet_objects


def unmerge_excel_cells_and_perserve_data(sheet_objects):
    

    # Test procedure on first sheet
    current_sheet = sheet_objects[0]

    merged_ranges = current_sheet.merged_cell_ranges

    # Fix single range
    current_range = merged_ranges[1]

    # Set range coordinates and get first in merged range value
    first_coord, second_cord = current_range.split(":")
    first_cell_value = current_sheet[first_coord].value

    # Generate cells id in range
    cells_in_merged_range = []
    for letter in range(ord(first_coord[0]),ord(second_cord[0])+1):
        letter_value = chr(letter)
        for number in range(int(first_coord[1]),int(second_cord[1])+1):
            cells_in_merged_range.append(letter_value+str(number))

    for cell in cells_in_merged_range:
        current_sheet[cell].value = first_cell_value



def convert_csv_to_array(directory):

    try:
        with open(directory, "r") as csv_file:
            file_ouput = csv.reader(csv_file)

            # Turn csv object into 3D array
            csv_rows = []
            for current_row in file_ouput:
                csv_rows.append(current_row)

            for row in csv_rows:
                print(row)


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
    main("1.test_data/B0.02 B0.03 B0.04 Timetable.xlsx")

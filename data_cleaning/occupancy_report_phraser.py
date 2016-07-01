# Author Devin Stacey and Conor O'Kelly

# Aim of this section will be to load in a occupancy excel file and convert the occupancy information into a array
# of dicts. Each containing the relevant information. Any derived information will be disregarded from the file

# Not the name of the work

import nose2
import openpyxl
import csv


def phrase_occupancy_excel_file(target_directory):

    excel_object = convert_excel_to_csv(target_directory)
    occupancy_data_array = phrase_data_from_csi_sheet_in_workbook(excel_object)


def convert_excel_to_csv(directory):

    try:
        # Load workbook with all sheets
        results_object = openpyxl.load_workbook(directory)

        return results_object

    except FileNotFoundError:
        print("Occupancy report was not found at", directory)
        return None


def phrase_data_from_csi_sheet_in_workbook(excel_workbook):

    # Taking only the CSI sheet from the excel document
    work_sheet = excel_workbook.get_sheet_by_name("CSI")
    print(work_sheet["A1"].value)




# Nose2 test

if __name__ == '__main__':
    phrase_occupancy_excel_file("1.test_data/CSI Occupancy report.xlsx")

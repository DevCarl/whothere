# Author Conor O'Kelly

# Aim of this module will to be check a directory for the presence of new files. If there is file / files the type if
# determined and the data phrased from the file. This data is then input into the sql data base.

# Return dict with information on success of program

# File type is determined if extension is CSV first. For excel check name of file => occupancy / timetable must
# be in their respective file's names

import os
import pymysql
# module imports
from wifi_log_phraser import phrase_csv_file_and_return_array_of_dicts
from occupancy_report_phraser import phrase_occupancy_excel_file
from timetable_phraser import phrase_timetable_excel_sheet_into_array_of_dicts

import nose2

# To suppress warnings while using editor - number of warning from pandas
import warnings


def phrase_data_and_input_into_database(new_data_directory="data_storage/new_data/"):

    # Get list of files in new data and remove those that are hidden
    new_files_list = os.listdir(new_data_directory)
    new_files_list = [file for file in new_files_list if file[0] is not "."]

    # If there are new files phrase and input into db
    if len(new_files_list) > 0:
        process_files(new_data_directory,new_files_list)
    else:
        return {"success": True, "new_data_exists": False, "data_input": False, "individual_file_reports": []}


def process_files(data_directory, file_list):

    processing_results = []
    # Cycle through the list of files and input into database
    for file in file_list:
        # print(data_directory+file)
        # Determine the type of the files
        file_type = determine_file_type(file)

        # type 0 unknown / csv type 1 / timetable type 2 / occupancy type 3
        if file_type == 1:
            file_data = phrase_csv_file_and_return_array_of_dicts(data_directory+file)
        elif file_type == 2:
            file_data = phrase_timetable_excel_sheet_into_array_of_dicts(data_directory+file)
        elif file_type == 3:
            file_data = phrase_occupancy_excel_file(data_directory+file)
        else:
            processing_results.append({"success": False, "data_input": False, "file_name": file,
                                       "error": "type could not be determined"})
            file_data = None

        # Continue if file data no blank
        print(file_data)


def determine_file_type(file):

    # type 0 unknown / csv type 1 / timetable type 2 / occupancy type 3

    # print(file)

    file_type = 0

    if ".csv" in file:
        file_type = 1
    elif "timetable" in file.lower():
        file_type = 2
    elif "occupancy" in file.lower():
        file_type = 3

    return file_type


def generate_list_of_modules():

    module_list = []

    return module_list


def input_file_into_db():

    # Open database connection - address, username, password, db
    db = pymysql.connect(host="localhost", user="root", password="", database="who_there_db")

    # prepare a cursor object using cursor() method
    cursor = db.cursor()

    # execute SQL query using execute() method.
    cursor.execute("select * from room")

    # Fetch a single row using fetchone() method.
    data = cursor.fetchone()

    print(data)

    # disconnect from server
    db.close()


if __name__ == '__main__':
    warnings.filterwarnings("ignore")
    # phrase_data_and_input_into_database()
    input_file_into_db()
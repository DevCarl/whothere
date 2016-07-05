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


def phrase_data_and_input_into_database(new_data_directory="data_storage/new_data"):

    # Get list of files in new data and remove those that are hidden
    new_files_list = os.listdir(new_data_directory)
    new_files_list = [file for file in new_files_list if file[0] is not "."]

    # If there are new files phrase and input into db
    if len(new_files_list) > 0:
        process_files(new_files_list)
    else:
        return {"success": True, "new_data_exists": False, "data_input": False, "multiple_files": False,
                "individual_file_reports": []}


def process_files(file_list):

    # Cycle through the list of files and input into database
    for file in file_list:
        # Determine the type of the files
        file_type = determine_file_type(file)

        # type 0 unknown / csv type 1 / timetable type 2 / occupancy type 3
        if file_type == 1:
            file_data = phrase_csv_file_and_return_array_of_dicts
        elif file_type == 2:
            file_data = phrase_timetable_excel_sheet_into_array_of_dicts()
        elif file_type == 3:
            file_data = phrase_occupancy_excel_file()


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


def input_file_into_db():

    # Connect to database
    import PyMySQL.connector

    cnx = PyMySQL.connector.connect(user='root', password='', host='127.0.0.1',database='mydb')
    cnx.close()

    return 1


if __name__ == '__main__':
    phrase_data_and_input_into_database()
# Author Conor O'Kelly

# Aim of this module will to be check a directory for the presence of new files. If there is file / files the type if
# determined and the data phrased from the file. This data is then input into the sql data base. A dict will be returned
# from the program with a break down of success reports on inputing the data.

# Rooms / Module must be input into the database first due to the foreign key relationship

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


def phrase_data_and_input_into_database(db_host_name, db_user_name, db_password, database_name, db_port=3306,
                                        new_data_directory="data_storage/new_data/"):

    # Convert db info into tuple
    db_tuple = (db_host_name, db_user_name, db_password, database_name, db_port)

    # Get list of files in new data and remove those that are hidden
    new_files_list = os.listdir(new_data_directory)
    new_files_list = [file for file in new_files_list if file[0] is not "."]

    # If there are new files phrase and input into db
    if len(new_files_list) > 0:
        process_files(new_data_directory, new_files_list, db_tuple)
    else:
        return {"success": True, "new_data_exists": False, "data_input": False, "individual_file_reports": []}


def process_files(data_directory, file_list, db_tuple):

    processing_results = []

    # unpack db tuple
    db_host_name, db_user_name, db_password, database_name, port = db_tuple

    # Cycle through the list of files and input into database
    for file in file_list:
        # print(data_directory+file)
        # Determine the type of the files
        file_type = determine_file_type(file)

        # type 0 unknown / csv type 1 / timetable type 2 / occupancy type 3
        if file_type == 1:
            file_data = phrase_csv_file_and_return_array_of_dicts(data_directory+file)
            rooms = generate_list_of_rooms(file_data)
            modules = []


        elif file_type == 2:
            file_data = phrase_timetable_excel_sheet_into_array_of_dicts(data_directory+file)
            modules = generate_list_of_modules(file_data)
            rooms = generate_list_of_rooms(file_data)

        elif file_type == 3:
            file_data = phrase_occupancy_excel_file(data_directory+file)
            rooms = generate_occupancy_rooms_list(file_data)
            modules = ["COMP2020"]

            # Insert files into the database
            input_file_into_db((file_data, rooms, modules, file_type), db_host_name, db_user_name, db_password,
                               database_name, port)

        else:
            processing_results.append({"success": False, "data_input": False, "file_name": file,
                                       "error": "type could not be determined"})
            file_data = None

        # Continue if file data no blank
        # print(file_type, file_data[0])

    # Build processing results return dict

    return


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


def generate_list_of_modules(data_array):

    module_list = []

    for dict in data_array:
        if dict.get("module") not in module_list:
            module_list.append(dict.get("module"))

    return module_list


def generate_list_of_rooms(data_array):

    room_list = []

    for dict in data_array:
        if dict.get("room") not in room_list:
            room_list.append(dict.get("room"))

    return room_list


def generate_occupancy_rooms_list(file_data):

    room_list = []

    for key in file_data[0]:
        if key != "date" and key != "time" and key != "building":
            room_list.append(key)

    return room_list


def input_file_into_db(data_to_be_input_tuple, db_host_name, db_user_name, db_password, database_name, db_port):

    # Open database connection and prepare cursor object
    db = pymysql.connect(host=db_host_name, user=db_user_name, password=db_password, database=database_name,
                         port=db_port, autocommit=True)
    cursor = db.cursor()

    # unpack database tuple
    general_data, room_list, module_list, data_type = data_to_be_input_tuple

    # First check all room / module are in db already. If not add them in.
    print(room_list)
    print(module_list)

    for room in room_list:
        cursor.execute("insert ignore into room values ("+room+");")

    for module in module_list:
        cursor.execute("insert ignore into module values ("+module+");")



    # Second depending on data type insert information into the database
    # type 0 unknown / csv type 1 / timetable type 2 / occupancy type 3

    # value = "('10', 'B003', 'CSI', '1', 'Belfied', 1, 90, 1)"
    # cursor.execute("insert ignore into room values "+value+";")
    # cursor.execute("select * from room")
    # data = cursor.fetchall()
    # print(data)

    # disconnect from server
    db.close()


if __name__ == '__main__':
    warnings.filterwarnings("ignore")
    phrase_data_and_input_into_database("localhost", "root", "", "who_there_db")
    # input_file_into_db((0,0,0,0), "localhost", "root", "", "who_there_db",3306)
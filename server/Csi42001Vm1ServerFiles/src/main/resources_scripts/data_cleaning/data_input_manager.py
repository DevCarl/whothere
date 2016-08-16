# Author Conor O'Kelly

# Aim of this module will to be check a directory for the presence of new files. If there is file / files the type if
# determined and the data phrased from the file. This data is then input into the sql data base. A dict will be returned
# from the program with a break down of success reports on inputing the data.

# Rooms / Module must be input into the database first due to the foreign key relationship

# File type is determined if extension is CSV first. For excel check name of file => occupancy / timetable must
# be in their respective file's names

import os
import zipfile
import pymysql
import calendar
import shutil
import datetime

# module imports
from wifi_log_phraser import phrase_csv_file_and_return_array_of_dicts
from occupancy_report_phraser import phrase_occupancy_excel_file
from timetable_phraser import phrase_timetable_excel_sheet_into_array_of_dicts
from generate_derived_data import derived_data_and_generate_indexs_from_db

import nose2

# To suppress warnings while using editor - number of warning from pandas
import warnings


def phrase_data_and_input_into_database(db_host_name, db_user_name, db_password, database_name, db_port=3306,
                                        new_data_directory="data_storage/new_data/", move_files_after=0):
    # Convert db info into tuple
    db_tuple = (db_host_name, db_user_name, db_password, database_name, db_port)

    # Get directory abs path
    base_data_directory = os.path.abspath(os.path.dirname(__file__))
    new_data_directory = base_data_directory + "/" + new_data_directory

    # Check directory path ends with "/". If not add it.
    if new_data_directory.endswith("/") == False:
        new_data_directory += "/"

    # Unzip files and remove zipped version
    unzip_files_and_remove_zip(new_data_directory)
    # Run unzip a second time to catch uploads that have been already zipped
    unzip_files_and_remove_zip(new_data_directory)

    # Get list of files in new data and remove those that are hidden
    new_files_list = os.listdir(new_data_directory)
    new_files_list = [file for file in new_files_list if file[0] is not "."]

    # Check if database exist. If not create it
    check_database_exists_if_not_create(db_tuple)

    # If there are new files phrase and input into db
    if len(new_files_list) > 0:
        results = process_files(new_data_directory, new_files_list, db_tuple)
    else:
        return {"success": True, "new_data_exists": False, "data_input": False, "individual_file_reports": []}

    # Move contents of new_data_directory to processed data
    if move_files_after == 1:
        for file_report in results:
            file_name = file_report.get("file_name")
            success = file_report.get("success")

            # print(file_report)
            # If successfully input into DB
            if success == True:
                shutil.move(new_data_directory+file_name, base_data_directory + "/data_storage/stored_data/")

            # If not successfully input into DB
            else:
                shutil.move(new_data_directory+file_name, base_data_directory + "/data_storage/failed_to_store_data/")

    # Store input logs
    store_input_logs(results, db_tuple)

    # Generate derived data and indexes
    derived_data_and_generate_indexs_from_db(db_host_name, db_user_name, db_password, database_name)


def store_input_logs(input_results, database_tuple):

    # unpack db tuple
    db_host_name, db_user_name, db_password, database_name, db_port = database_tuple

    # Open database connection and prepare cursor object
    db = pymysql.connect(host=db_host_name, user=db_user_name, password=db_password, database=database_name,
                         port=db_port, autocommit=True)
    cursor = db.cursor()

    for result in input_results:
        # print(result)
        file_name = result.get("file_name")
        if result.get("data_input") == True:
            success = 1
        else:
            success = 0

        error = result.get("error")
        time_stamp = str(datetime.datetime.today())

        cursor.execute("insert ignore into Input_logs (File_name,Success,Error_report,Input_timestamp) values "
                       "('"+file_name+"','"+str(success)+"','"+error+"','"+time_stamp+"');")

    db.close()


def unzip_files_and_remove_zip(directory):

    # Iterated through directory. Find zip files. Unzip and remove ziped version
    for item in os.listdir(directory):
        if item.endswith(".zip"):
            # print(item)
            zip_ref = zipfile.ZipFile(directory+item)
            zip_ref.extractall(directory)
            zip_ref.close()
            os.remove(directory+item)


def check_database_exists_if_not_create(db_tuple):

    # unpack db tuple
    db_host_name, db_user_name, db_password, database_name, port = db_tuple

    # print(db_host_name, db_user_name, db_password, database_name, port)

    # Open database connection and prepare cursor object
    db_1 = pymysql.connect(db_host_name, db_user_name, db_password, "")
    cursor = db_1.cursor()

    # Load sql creation info from file
    base_data_directory = os.path.abspath(os.path.dirname(__file__))
    sql_location = base_data_directory + "/database_schema/who_there_db.sql"
    sql_file = open(sql_location, "r")
    # print(sql_file.read())

    cursor.execute(sql_file.read())

    # Fix for wifi_logs not being found
    cursor.execute("show tables;")
    cursor.fetchall()

    # disconnect from server
    db_1.close()


def process_files(data_directory, file_list, db_tuple):

    processing_results = []

    # unpack db tuple
    db_host_name, db_user_name, db_password, database_name, port = db_tuple

    # Cycle through the list of files and input into database
    for file in file_list:
        try:
            # print(data_directory+file)
            # Determine the type of the files
            file_type = determine_file_type(file)

            # type 0 unknown / csv type 1 / timetable type 2 / occupancy type 3
            if file_type == 1:
                file_data = phrase_csv_file_and_return_array_of_dicts(data_directory+file)
                rooms = generate_list_of_rooms(file_data)
                modules = []

                # Insert files into the database
                input_file_into_db((file_data, rooms, modules, file_type), db_host_name, db_user_name, db_password,
                                   database_name, port)
                processing_results.append({"success": True, "data_input": True, "file_name": file,
                                           "error": "None"})

            elif file_type == 2:
                file_data = phrase_timetable_excel_sheet_into_array_of_dicts(data_directory+file)
                modules = [moudle for moudle in generate_list_of_modules(file_data) if moudle != None]
                rooms = generate_list_of_rooms(file_data)

                # Insert files into the database
                input_file_into_db((file_data, rooms, modules, file_type), db_host_name, db_user_name, db_password,
                                   database_name, port)
                processing_results.append({"success": True, "data_input": True, "file_name": file,
                                           "error": "None"})

            elif file_type == 3:
                file_data = phrase_occupancy_excel_file(data_directory+file)
                rooms = generate_list_of_rooms(file_data)
                room_capacity_dict = generate_capacity_list(file_data)
                modules = []

                # Insert files into the database
                input_file_into_db((file_data, rooms, modules, file_type,), db_host_name, db_user_name, db_password,
                                   database_name, port, capacity_dict=room_capacity_dict)

                processing_results.append({"success": True, "data_input": True, "file_name": file,
                                           "error": "None"})

            else:
                processing_results.append({"success": False, "data_input": False, "file_name": file,
                                           "error": "type could not be determined"})
                file_data = None
        except:
            processing_results.append({"success": False, "data_input": False, "file_name": file,
                                       "error": "file could not be input into the database"})

    # Move contents of new date to

    return processing_results


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


def generate_capacity_list(file_data):

    capacity_dict = {}

    for data_row in file_data:
        if data_row.get("room") not in capacity_dict:
            capacity_dict[data_row.get("room")] = data_row.get("capacity")
            # print(data_row.room)

    return capacity_dict


def input_file_into_db(data_to_be_input_tuple, db_host_name, db_user_name, db_password, database_name, db_port,
                       capacity_dict={}):

    # Open database connection and prepare cursor object
    db = pymysql.connect(host=db_host_name, user=db_user_name, password=db_password, database=database_name,
                         port=db_port, autocommit=True)
    cursor = db.cursor()

    # unpack database tuple
    general_data, room_list, module_list, data_type = data_to_be_input_tuple

    # Create empty room moudle code
    cursor.execute("insert ignore into Module (Module_code) values ('0');")

    ### First check all room / module are in db already. If not add them in.

    # Filter room list and then insert missing ones
    cursor.execute("select Room_no from Room;")
    rooms_in_db = [i[0] for i in cursor.fetchall()]
    missing_rooms = list(set(room_list) - set(rooms_in_db))

    # Insert into DB
    for room in missing_rooms:
        cursor.execute("insert ignore into Room (Room_no) values ('"+room+"');")

    # Filter module list and the insert missing ones

    cursor.execute("select Module_code from Module;")
    modules_in_db = [i[0].upper() for i in cursor.fetchall()]
    missing_modules = list(set(module_list) - set(modules_in_db))

    # Insert missing modules into db
    for module in missing_modules:
        cursor.execute("insert ignore into Module (Module_code) values ('"+module+"');")

    # Second update room capacities if required
    # Check that a capacity dict and been given. If room in database has null capacity update it if possible
    if len(capacity_dict) > 0:
        for room in capacity_dict:
            cursor.execute("select Capacity from Room where Room_no='"+room+"';")
            room_capacity = cursor.fetchone()[0]
            # print(room_capacity)
            if room_capacity == None:
                cursor.execute("update Room set Capacity="+str(capacity_dict.get(room))+" where Room_no='"+room+"';")



    # Third depending on data type insert information into the database
    # type 0 unknown / csv type 1 / timetable type 2 / occupancy type 3

    # print(data_type, general_data[0])

    if data_type == 1:
        for current_data in general_data:
            # print(current_data)

            # Get room_id for current room
            room = current_data.get("room")
            cursor.execute("select Room_id from Room where Room_no='"+room+"';")
            room_id = cursor.fetchone()[0]
            # Assign other variables
            month = current_data.get("date").split(" ")[-2]
            date = current_data.get("year") + "-" + str(list(calendar.month_abbr).index(month)) + "-" + \
                   current_data.get("date").split(" ")[-1]

            time = current_data.get("time_stamp").split(" ")[3]
            associated_client_counts = current_data.get("associated_count")
            authenticated_client_counts = current_data.get("authenticated_count")

            cursor.execute("insert ignore into Wifi_log (Room_Room_id,Date,Time,"
                           "Associated_client_counts,Authenticated_client_counts) values "
                           "('"+str(room_id)+"','"+date+"','"+time+"','"+str(associated_client_counts)+"','"+
                           str(authenticated_client_counts)+"');")

    elif data_type == 2:
        for current_data in general_data:

            # Get room_id for current room
            room = current_data.get("room")
            cursor.execute("select Room_id from Room where Room_no='"+room+"';")
            room_id_fet = cursor.fetchone()[0]

            # Generate variables
            date_unformated = current_data.get("date").split("/")
            date = "20" + date_unformated[2] + "/" + date_unformated[1] + "/" + date_unformated[0]
            time_period = current_data.get("time").split("-")[0]
            room_id = room_id_fet
            module_id = current_data.get("module")
            if module_id == None:
                module_id = 0
            no_expected_students = current_data.get("no_expected_students")
            if no_expected_students == None:
                no_expected_students = 0
            tutorial = current_data.get("practical")
            double_module = current_data.get("shared_time_slot")
            # convert true to 1 and 0 to false
            if current_data.get("class_appeared_to_go_ahead") == True:
                class_went_ahead = 1
            else:
                class_went_ahead = 0

            cursor.execute("insert ignore into Time_table (Date, Time_period, Room_room_id, Module_module_code, "
                           "No_expected_students, Tutorial, Double_module, Class_went_ahead) "
                           "values ('"+date+"','"+time_period+"','"+str(room_id)+"','"+str(module_id)+"','"+str(no_expected_students)+"','"
                           + str(tutorial)+"','"+str(double_module)+"','"+str(class_went_ahead)+"');")

    elif data_type == 3:

        for current_line in general_data:
            # print(current_line)

            # Reformate time into timestamp
            time = current_line.get("time").split("-")[0].replace(".", ":")
            date = current_line.get("date")
            room_name = current_line.get("room")
            percentage_room_full = current_line.get("occupancy")

             # Get room_id for current room
            cursor.execute("select Room_id from Room where Room_no='"+room_name+"';")
            room_id = cursor.fetchone()[0]

            # print(time, date, room_name, room_id, percentage_room_full)

            cursor.execute("insert ignore into Ground_truth_data (Room_Room_id, date, time, Percentage_room_full) "
                           "values ('"+str(room_id)+"','"+date+"','"+time+"','"+str(percentage_room_full)+"');")

    # disconnect from server
    db.close()


if __name__ == '__main__':
    warnings.filterwarnings("ignore")
    phrase_data_and_input_into_database("localhost", "root", "goldilocks", "who_there_db", move_files_after=1)
    # phrase_data_and_input_into_database("localhost", "root", "goldilocks", "who_there_db")
    # input_file_into_db((0,0,0,0), "localhost", "root", "goldilocks", "who_there_db",3306)

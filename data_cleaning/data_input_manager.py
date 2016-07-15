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

    # Check directory path ends with "/". If not add it.
    if new_data_directory.endswith("/") == False:
        new_data_directory += "/"

    # Unzip files and remove zipped version
    unzip_files_and_remove_zip(new_data_directory)

    # Get list of files in new data and remove those that are hidden
    new_files_list = os.listdir(new_data_directory)
    new_files_list = [file for file in new_files_list if file[0] is not "."]

    # If there are new files phrase and input into db
    if len(new_files_list) > 0:
        process_files(new_data_directory, new_files_list, db_tuple)
    else:
        return {"success": True, "new_data_exists": False, "data_input": False, "individual_file_reports": []}


def unzip_files_and_remove_zip(directory):

    # Iterated through directory. Find zip files. Unzip and remove ziped version
    for item in os.listdir(directory):
        if item.endswith(".zip"):
            # print(item)
            zip_ref = zipfile.ZipFile(directory+item)
            zip_ref.extractall(directory)
            zip_ref.close()
            os.remove(directory+item)


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

            # Insert files into the database
            input_file_into_db((file_data, rooms, modules, file_type), db_host_name, db_user_name, db_password,
                               database_name, port)

        elif file_type == 2:
            file_data = phrase_timetable_excel_sheet_into_array_of_dicts(data_directory+file)
            modules = [moudle for moudle in generate_list_of_modules(file_data) if moudle != None]
            rooms = generate_list_of_rooms(file_data)

            # Insert files into the database
            input_file_into_db((file_data, rooms, modules, file_type), db_host_name, db_user_name, db_password,
                               database_name, port)

        elif file_type == 3:
            file_data = phrase_occupancy_excel_file(data_directory+file)
            rooms = generate_occupancy_rooms_list(file_data)
            modules = []

            # Insert files into the database
            input_file_into_db((file_data, rooms, modules, file_type), db_host_name, db_user_name, db_password,
                               database_name, port)

        else:
            processing_results.append({"success": False, "data_input": False, "file_name": file,
                                       "error": "type could not be determined"})
            file_data = None

    # Move contents of new date to

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

    # Create empty room moudle code
    cursor.execute("insert ignore into Module (Module_code) values ('0');")

    # First check all room / module are in db already. If not add them in.

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

    # Second depending on data type insert information into the database
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
            # print(general_data[0])
            time = current_line.get("time")
            date = current_line.get("date")
            room_B002 = current_line.get("B002")

            # Get room_id for current room
            room = "B002"
            cursor.execute("select Room_id from Room where Room_no='"+room+"';")
            room_id = cursor.fetchone()[0]
            cursor.execute("insert ignore into Ground_truth_data (Room_Room_id, date, time, Percentage_room_full) "
                           "values ('"+str(room_id)+"','"+date+"','"+time+"','"+str(room_B002)+"');")

            room_B003 = current_line.get("B003")
            # Get room_id for current room
            room = "B003"
            cursor.execute("select Room_id from Room where Room_no='"+room+"';")
            room_id = cursor.fetchone()[0]
            cursor.execute("insert ignore into Ground_truth_data (Room_Room_id, date, time, Percentage_room_full) "
                           "values ('"+str(room_id)+"','"+date+"','"+time+"','"+str(room_B003)+"');")

            room_B004 = current_line.get("B004")
            # Get room_id for current room
            room = "B004"
            cursor.execute("select room_id from Room where room_no='"+room+"';")
            room_id = cursor.fetchone()[0]
            cursor.execute("insert ignore into Ground_truth_data (Room_Room_id, date, time, Percentage_room_full) "
                           "values ('"+str(room_id)+"','"+date+"','"+time+"','"+str(room_B004)+"');")

            room_B106 = current_line.get("B106")
            # Get room_id for current room
            room = "B106"
            cursor.execute("select room_id from Room where room_no='"+room+"';")
            room_id = cursor.fetchone()[0]
            cursor.execute("insert ignore into Ground_truth_data (Room_Room_id, date, time, Percentage_room_full) "
                           "values ('"+str(room_id)+"','"+date+"','"+time+"','"+str(room_B106)+"');")

            room_B108 = current_line.get("B108")
            # Get room_id for current room
            room = "B108"
            cursor.execute("select Room_id from Room where Room_no='"+room+"';")
            room_id = cursor.fetchone()[0]
            cursor.execute("insert ignore into Ground_truth_data (Room_Room_id, date, time, Percentage_room_full) "
                           "values ('"+str(room_id)+"','"+date+"','"+time+"','"+str(room_B108)+"');")

            room_B109 = current_line.get("B109")
            # Get room_id for current room
            room = "B109"
            cursor.execute("select room_id from Room where Room_no='"+room+"';")
            room_id = cursor.fetchone()[0]
            cursor.execute("insert ignore into Ground_truth_data (Room_Room_id, date, time, Percentage_room_full) "
                           "values ('"+str(room_id)+"','"+date+"','"+time+"','"+str(room_B109)+"');")



    # value = "('10', 'B003', 'CSI', '1', 'Belfied', 1, 90, 1)"
    # cursor.execute("insert ignore into room values "+value+";")
    # cursor.execute("select * from room")
    # data = cursor.fetchall()
    # print(data)

    # disconnect from server
    db.close()


if __name__ == '__main__':
    warnings.filterwarnings("ignore")
    phrase_data_and_input_into_database("localhost", "root", "goldilocks", "who_there_db")
    # input_file_into_db((0,0,0,0), "localhost", "root", "goldilocks", "who_there_db",3306)


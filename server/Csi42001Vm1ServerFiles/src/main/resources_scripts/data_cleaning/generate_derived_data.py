# Author Conor O'Kelly

# The aim of this moudle will be to scan through the database and generate derived data where possible.
# This module will also generate indexes and derived tables

# An example of this is that all modules starting first number represents their level


import nose2
import pymysql
import re


def derived_data_and_generate_indexs_from_db(db_host_name, db_user_name, db_password, database_name, db_port=3306):

    # Connect to the data base and make cursor object
    db = pymysql.connect(host=db_host_name, user=db_user_name, password=db_password, database=database_name,
                         port=db_port, autocommit=True)

    # print("yes")
    db_cursor = db.cursor(pymysql.cursors.DictCursor)

    # Derive room table data
    derive_room_table_data(db_cursor)

    # Derive module table data
    derive_module_table_data(db_cursor)

    # print("done")
    # Created derived tables

    # Created indexes



# Room table => derived building no / floor no / plug friendly
def derive_room_table_data(db_cursor):

    db_cursor.execute("select * from Room;")
    result_array = [i for i in db_cursor.fetchall()]

    # Cycle through results and add in missing data
    for row in result_array:
        # print(row)
        room_id = row.get("Room_id")
        room_no = row.get("Room_no")
        room_capacity = row.get("Capacity")

        # Cycle through and update columns. Add comma to each at end and remove comma from last one.
        update_string = ""

        if row.get("Building") is None and room_no[0] == "B":
            update_string += "Building='Computer Science and Informatics Centre',"

        # Return first no for room using regex
        if row.get("Floor_no") and re.search(r'\d', room_no) is not None:
            update_string += " Floor_no= " + re.search(r'\d', room_no).group() + ","

        if row.get("Campus") is None:
            update_string += " Campus='Belfield',"

        if row.get("Plug_friendly") is None and room_no[0] == "B":
            update_string += " Plug_friendly=1,"

        if row.get("Plug_friendly") is None and room_no[0] != "B":
            update_string += " Plug_friendly=0,"

        # Remove comma from end of update string
        insert_string = update_string[0:-1]

        sql_string = "update Room set " + insert_string + " where Room_id=" + str(room_id) + ";"

        # Execute statement
        if len(update_string) > 0:
            db_cursor.execute(sql_string)


# Module table => Facility / course level / undergrad
def derive_module_table_data(db_cursor):

    db_cursor.execute("select * from Module;")
    result_array = [i for i in db_cursor.fetchall()]

    # Cycle through results and add in missing data
    for row in result_array:
        module_code = row.get("Module_code")

        update_string = ""

        # Facilty
        facility = re.findall(r'[A-z]', module_code)
        facility = ''.join(facility)

        if row.get("Facilty") is None and len(facility) > 0:
            update_string += " Facilty='" + facility + "',"

        # Course level
        course_level = 0
        course_level_re = re.search(r'\d', module_code)

        if row.get("Course_level") is None and course_level_re is not None:
            update_string += " Course_level='" + course_level_re.group() + "',"
            course_level = int(course_level_re.group())

        # Undergrad
        if course_level <= 3:
            grad_level = "1"
        elif course_level >3:
            grad_level = "0"

        if row.get("Undergrad") is None and course_level_re is not None:
            update_string += " Undergrad='" + grad_level + "',"


        # Remove last comma
        insert_string = update_string[0:-1]

        sql_string = "Update Module set" + insert_string + " where Module_code='" + module_code + "';"

        if len(update_string) > 0:
            db_cursor.execute(sql_string)

# Buildings auto insert list

# Generate derived table

if __name__ == '__main__':
    derived_data_and_generate_indexs_from_db("localhost", "root", "goldilocks", "who_there_db",)
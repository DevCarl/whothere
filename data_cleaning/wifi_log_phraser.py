# Author Devin Stacey and Conor O'Kelly

# The aim of this section will be to load the wifi log stored in CSV format. This will then be converted into a
# list of dicts to be used to insert into the database

import csv
import nose2


def phrase_csv_file_and_return_array_of_dicts(target_directory):

    csv_data = load_csv_file_and_return_data(target_directory)

    phrased_information = convert_csv_array_into_info_dicts(csv_data)

    return phrased_information


def load_csv_file_and_return_data(target_directory):

    csv_array = []

    try:
        with open(target_directory, "r") as csvfile:
            reader = csv.reader(csvfile)
            for row in reader:
                csv_array.append(row)
    except FileNotFoundError:
        print("CSV file for wifi logs at",target_directory,"was not found.")

    return csv_array


def convert_csv_array_into_info_dicts(current_csv_array):

    # Can be easily changed to cycle more the one set of row per a sheet
    csv_information_array = []

    # Disregard all data above row containing key
    start_location = 20
    for row in current_csv_array:
        if row[0].lower() == "key":
            start_location = current_csv_array.index(row)
    # Cycle through remaining rows. For each create dict off all info and add to sheet array
    for row in current_csv_array[start_location+1:]:
        location = row[0].split(">")
        campus = location[0].strip()
        building = location[1].strip()
        room = location[2].strip().replace("-", "")

        time_stamp = row[1]
        date = " ".join(time_stamp.split(" ")[0:3])
        year = time_stamp.split(" ")[5]
        time = time_stamp.split(" ")[3]

        # print(time_stamp, "gap", time, date, year)
        associated_count = row[2]
        authenticated_count = row[3]

        # Create dict
        row_dict = {"campus": campus, "building": building, "room": room, "time_stamp": time_stamp,
                    "date": date, "year": year, "time": time, "associated_count": associated_count,
                    "authenticated_count": authenticated_count}

        csv_information_array.append(row_dict)

    return csv_information_array

# nose2 test


def test_load_csv_file_and_return_data_returns_array():

    result = load_csv_file_and_return_data("1.test_data/Client_Count_CSCI_B-02_20151106_143000_079.csv")
    assert type(result) == list


if __name__ == '__main__':
    phrase_csv_file_and_return_array_of_dicts("1.test_data/Client_Count_CSCI_B-02_20151106_143000_079.csv")
    nose2.main()
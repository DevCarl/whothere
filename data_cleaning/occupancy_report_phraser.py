# Author Devin Stacey and Conor O'Kelly

# Aim of this section will be to load in a occupancy excel file and convert the occupancy information into a array
# of dicts. Each containing the relevant information. Any derived information will be disregarded from the file

# Script possibly dependant on the name of the name of the worksheet?????

import nose2
import openpyxl
import pandas as pd
import dateutil.parser

# To suppress warnings while using editor - number of warning from pandas
import warnings


def phrase_occupancy_excel_file(target_directory):

    pandas_data_frame = return_data_frame_from_excel_using_pandas(target_directory)
    results_array = convert_data_frame_into_dict_array(pandas_data_frame)

    return results_array


def return_data_frame_from_excel_using_pandas(directory):

    df = pd.read_excel(open(directory, "rb"), sheetname = "CSI")
    df = df.loc[df.count(axis=1) > 1]

    first = True
    df["Date"] = 0
    date = 0
    CSIList = ["CSI Classroom FREQUENCY OF USE", "CSI Classroom OCCUPANCY"]
    CSICurrent = None
    CSIStart, CSIEnd = 0, 0
    for i in df.index:
        try:
            date = dateutil.parser.parse(df[0][i])
        except:
            pass
        if df[0][i] == "CSI Classroom OCCUPANCY":
            CSICurrent = df[0][i]
            CSIStart = i
        elif df[0][i] == "CSI Classroom UTILISATION":
            dfOccupancy = df[(df.index >= CSIStart) & (df.index < i)]
            dfOccupancy["Date"] = date
            if first:
                dfFull = dfOccupancy
                first = False
            else:
                dfFull = pd.concat([dfFull, dfOccupancy])

    building_list = ["CSI"]
    check_columns = []
    occupancy = {}

    for column in dfFull:
        if "CSI" in dfFull[column].values:
            check_columns.append(column)

    for i in dfFull.index:
        if dfFull[check_columns[0]][i] in building_list:
            for column in range(0, len(check_columns)):
                column2 = dfFull[check_columns[column]][i] + "-" + dfFull[check_columns[column]][i+1]
                dfFull = dfFull.rename(columns={check_columns[column]: column2})
                check_columns[column] = column2
                occupancy[column2] = dfFull[check_columns[column]][i+2]
            break

    dfFull = dfFull.rename(columns={0: "Time"})
    timeslots = ["9.00-10.00", "10.00-11.00", "11.00-12.00", "12.00-13.00", "13.00-14.00", "14.00-15.00", "15.00-16.00", "16.00-17.00"]
    dfFull = dfFull[dfFull['Time'].isin(timeslots)]
    dfFull = dfFull.dropna(axis=1,how='all')

    return dfFull


def convert_data_frame_into_dict_array(pandas_data_frame):

    all_data_array = []

    # Convert frame into matrix and get column names
    rows_in_array = pandas_data_frame.as_matrix()
    column_name = pandas_data_frame.columns.values

    # Convert each row into a dict
    for current_row in rows_in_array:
        current_dict = {"time": current_row[0], "building": "CSI", "BOO4": current_row[1], "BOO2": current_row[2],
                        "B003": current_row[3], "B106": current_row[4], "B108": current_row[5], "B109": current_row[6],
                        "date": str(current_row[7]).split(" ")[0]}
        # Date is converted from timestamp object into string

        # Append current dict to array
        all_data_array.append(current_dict)

    # print(all_data_array)
    return all_data_array


# Not currently being used
def load_excel_file(directory):

    try:
        # Load workbook with all sheets
        results_object = openpyxl.load_workbook(directory)

        return results_object

    except FileNotFoundError:
        print("Occupancy report was not found at", directory)
        return None


# Not currently being used
def phrase_data_from_csi_sheet_in_workbook(excel_workbook):

    # Taking only the CSI sheet from the excel document
    work_sheet = excel_workbook.get_sheet_by_name("CSI")
    print(work_sheet["A1"].value)


# Nose2 test

if __name__ == '__main__':
    warnings.filterwarnings("ignore")
    data = phrase_occupancy_excel_file("1.test_data/CSI Occupancy report.xlsx")
    print(data)

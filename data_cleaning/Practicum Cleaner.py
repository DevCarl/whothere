import numpy as np
import json
import csv
import pandas as pd
import os
import zipfile
import dateutil.parser

# This section will clean CSI Wifi Logs

first = True
directory = "Documents/College/Practicum/Client_Count"
x = os.listdir(directory)
for i in x:
    local_location = directory + "/" + i
    contents = os.path.splitext(i)[0]
    df = pd.read_csv(local_location, compression="infer", skiprows=7)
    dfDirty = df[df['Associated Client Count'].apply(lambda x: str(x).isdigit())]
    dfTotal = dfDirty.loc[dfDirty["Total Count"] == "total"]
    dfRoomKey = dfDirty.loc[dfDirty["Total Count"] != "total"]
    dfMerge = pd.merge(dfTotal, dfRoomKey, left_on="Event Time", right_on="Event Time", how="inner")
    if first:
        dfClean = dfMerge
        first = False
    else:
        dfClean = pd.concat([dfClean, dfMerge])

dfClean["Event Time"] = pd.to_datetime(dfClean["Event Time"])
dfClean = dfClean.sort_values(by='Event Time')
dfClean = dfClean.reset_index().drop("index", 1)


# This Section is dedicated to cleaning the CSI Occupancy Report

directory = "Documents/College/Practicum"
local_location = directory + "/" + "CSI Occupancy report.xlsx"
df = pd.read_excel(open(local_location, "rb"), sheetname = "CSI")
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
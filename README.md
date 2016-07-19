# whothere

Introduction


This project is undertaken as group of four as part of the UCD Computer Science Conversion MSc research partcicum.

The core aim of the project is to work together as a group using the agile methodolgy. 
The goal of the project is to use  wifi log data to predict the number of studnets that are currently in a room. This will be based on the number of devices that are connected to the network.


<b> Start Up Process </b>

In order to start the server for this project, you must redirect to whothere/server/Csi42001Vm1ServerFiles and run:
mvn spring-boot:run

From there, you can access the web pages available on the server.

<b> API </b>

To access the API, there are two important methods depending on the data required.

On your browser, the extension for collection Tables is api/table
The following language is used...
api/table?request=[table name]
Example:
api/table?request=Wifi_log
This will return a string in JSONArray format with information regarding to all the rows found within that table.

If a collection of all data is required, the extension is api/data
The following language is used...
api/data?request=[Date/Week/Room/Module]&[Date/Week/Room/Module]=[Search Query]
Example:
api/data?request=Date&Date=2015/11/11        ||        api/data?request=Module&Module=COMP30650
This will return a JSONObject with information collected from all tables, but limited to your Search Query.

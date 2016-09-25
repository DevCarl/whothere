<b> Introduction </b>

UCD required an efficient cost effective system that would estimate the level of room util- isation across the campus. The current system costs approximately 25,000 Euros a year to run and requires individuals to manually check rooms on campus 15 minutes after classes have started. They estimate the levels of occupancy based on the following bins: 0% 25% 50% 75% and 100% This information is used by UCD to assist in the allocation of rooms.

Problems with the current system:
<ul>
<li> High costs </li>
<li> Short term observation </li>
<li> Issues with estimating actual numbers of individuals in the room with only a short observation </li>
<li> Labour intensive </li>
</ul>

The main objective of the project is to create an automated system that could generate this data efficiently, more cost effectively and less labour intensive for UCD’s administration department.
To achieve the required outcome necessitated combing data into a model and then presenting our results. The raw data sources were as follows;

<ul>
<li> Wifi logs of connected users specific to room level access points. </li>
<li> Timetables detailing modules and number of expected individuals. </li>
<li> Two week period of surveys to act as ground truth. </li>
</ul>

￼This information would first have to be cleaned and then correctly stored for later work.
The analysed data was then used to build our model. The data model would define the relationship between number of devices connected and the number of individuals present at the time. The results are then stored in the database.
A graphical interface was then used to present a clear overview of our results to users. This would take the form of a website application run by the server allocated to our team.
The team were also encouraged to make innovations based on the core requirements and feedback received from the customer. This is to add additional functionality to the overall product. These innovations separate out different teams.

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

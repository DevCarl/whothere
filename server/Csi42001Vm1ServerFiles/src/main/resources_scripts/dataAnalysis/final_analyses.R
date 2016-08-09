#Final model

#upload the necessary packages
library(RMySQL)
library(nlme)
library(caret) # for splitting the database
library(nnet)#package for running multinomial regression

#<-----------------------------SELECT THE DATA FROM THE DATABASE ------------------------------>

#set up connection for server
connection <- dbConnect(MySQL(),user="root", password="goldilocks",dbname="who_there_db", host="localhost")
#connect from xamp
#connection <- dbConnect(MySQL(),user="root", password="",dbname="who_there_db", host="localhost")

#create the query
query <-"SELECT W.`Room_Room_id` as Room, W.`Date`, HOUR( W.Time ) as Time, T.`Module_Module_code` as Module, M.`Course_Level`,T.`Tutorial`, T.`Double_module`, T.`Class_went_ahead`, R.`Capacity`, G.`Percentage_room_full`, AVG(W.`Associated_client_counts`) as Wifi_Average_logs, MAX(W.`Authenticated_client_counts`) as Wifi_Max_logs FROM Room R, Wifi_log W, Ground_truth_data G, Time_table T, Module M WHERE W.Room_Room_id = R.Room_id AND G.Room_Room_id = W.Room_Room_id AND W.Date = G.Date AND HOUR( W.Time ) = HOUR( G.Time ) AND HOUR( W.Time ) = HOUR( T.Time_period ) AND T.Date = W.Date AND T.Room_Room_id = W.Room_Room_id AND M.`Module_code` = T.`Module_Module_code` GROUP BY W.Room_Room_id, HOUR( W.Time ) , W.Date"

#select the data based on the query and store them in a dataframe called Analysis table
AnalysisTable <-dbGetQuery(connection, query)

# <--------------------------- EXPLORATORY ANALYSES --------------------------->
#create the new column for getting number of people counted through ground truth data
AnalysisTable$Survey_occupancy <- AnalysisTable$Capacity * AnalysisTable$Percentage_room_full

#bin percentage_room_full into a categorical variable
AnalysisTable$Binned_Occupancy <-cut(AnalysisTable$Percentage_room_full, breaks = 4, right=FALSE, labels=c('Low','Mid_Low','Mid_High', 'High'))

#bin time into a categorical variable for checking time of the day
AnalysisTable$Factor_Time <-cut(AnalysisTable$Time, breaks = 4, right=FALSE, labels=c('Early Morning','Late Morning','Early Afternoon','Late Afternoon' ))

#specifiy as factor: Module, Course_Levels, Tutorial, Double Module and Class went ahead
AnalysisTable$Room <- factor(AnalysisTable$Room)
AnalysisTable$Course_Level <- factor(AnalysisTable$Course_Level)
AnalysisTable$Tutorial <- factor(AnalysisTable$Tutorial)
AnalysisTable$Double_module <- factor(AnalysisTable$Double_module)
AnalysisTable$Class_went_ahead <- factor(AnalysisTable$Class_went_ahead)

#Create a new dataset removing the outliers for running linear regression
NoOutlierTable <- AnalysisTable[ AnalysisTable$Wifi_Max_logs < 150,] 
NoOutlierTable <- NoOutlierTable[ NoOutlierTable$Survey_occupancy < 120,] 

#best model for linear regression
best.lm <- lm(Survey_occupancy ~ Wifi_Average_logs, data=NoOutlierTable)

#best model for multinomial regression
best.logit <-multinom(Binned_Occupancy ~ Wifi_Average_logs+Room, data=AnalysisTable,maxit=1000)

#create table with the prediction of the linear model(213 observations)
prediction <-data.frame(Room=NoOutlierTable$Room , Date=NoOutlierTable$Date, Time=NoOutlierTable$Time,predict(best.lm, interval="confidence"))

#create table with the predicion of the multinom model(216 observations)
table <-data.frame(Room=AnalysisTable$Room, Date=AnalysisTable$Date, Time=AnalysisTable$Time, Logistic_occupancy=predict(best.logit))

#create the table to export the output of the analysis
output <- merge(table, prediction, by= c("Room","Date","Time"),all.x= TRUE)
output[is.na(output)] <- "NULL"

#query for insert model prediction into the dataset 
for(i in 1:nrow(output)) {
  row <- output[i,]
  insert_query <- "INSERT INTO Processed_data (Time_table_Date, Time_table_Time_period, Time_table_Room_Room_id, People_estimate, Min_people_estimate, Max_people_estimate, Logistic_occupancy) VALUES(%s, %s, %s, %s, %s, %s, %s) ON DUPLICATE KEY UPDATE Time_table_Date = %s, Time_table_Time_period = %s, Time_table_Room_Room_id = %s, People_estimate = %s, Min_people_estimate = %s, Max_people_estimate = %s, Logistic_occupancy = %s"
  date <- paste("'", output[i,]$Date, "'")
  hour <- paste("STR_TO_DATE('", output[i,]$Time, "', '%H')")
  if (nchar(hour) <= 0){
    hour <- paste("0", hour)
  }
  logis <- paste("'", output[i,]$Logistic_occupancy, "'")
  room <- toString(output[i,]$Room)
  insert_query <- sprintf(insert_query, date, hour, room, toString(output[i,]$fit), toString(output[i,]$lwr), toString(output[i,]$upr), logis, date, hour, room, toString(output[i,]$fit), toString(output[i,]$lwr), toString(output[i,]$upr), logis)
  dbGetQuery(connection, insert_query)
}

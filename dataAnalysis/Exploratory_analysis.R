# <-------------------------------------- DATABASE --------------------------->
#In this section the connection with the database is made, database tables 
# are checked and the quiery to selected the data needed for the analysis is selected

#Library needed for carrying out the analyses

library(RMySQL) #package for communicate with MySQL database
library(ggplot2) #package for making graphs
library(AED) #package for making graphs
library(GGally)
source("http://peterhaschke.com/Code/multiplot.R")


#set up connection
#connection <- dbConnect(MySQL(),user="root", password="goldilocks",dbname="who_there_db", host="localhost")
#connect from xamp
connection <- dbConnect(MySQL(),user="root", password="",dbname="who_there_db", host="localhost")

#get the list of tables present in the DB: dbListTables(nameOfConnection)
dbListTables(connection)

#show the field names for a given table: dbListFields(connection, table name).
dbListFields(connection, "Room")

#create the query
query1 <-"SELECT `wifi_log`.`Date`, EXTRACT(Hour from `Time`) as 'wifi_time', EXTRACT(Hour from `Time_period`) as 'table_time' , `wifi_log`.`Room_Room_id` as 'Room',`Module_Module_code` as 'Module', `No_expected_students`, avg(`Associated_client_counts`) as 'Average_clients', MAX(`Associated_client_counts`) as 'Max_Client',`Tutorial`,`Double_module`,`Class_went_ahead` FROM `wifi_log`, `time_table` WHERE EXTRACT(Hour from `Time`) = EXTRACT(Hour from `Time_period`) GROUP BY hour(time), Date, `wifi_log`.`Room_Room_id` ORDER BY Date, `wifi_log`.`Room_Room_id`"
Table1 <-dbGetQuery(connection, query1)

#select the data based on the query and store them in a dataframe called Analysis table
AnalysisTable <-dbGetQuery(connection, query1)

# <--------------------------- EXPLORATORY ANALYSES --------------------------->


#get the dimension of the datasets
dim (AnalysisTable)

#get the first six rows of the dataset (by default)
head(AnalysisTable)

#get the last six rows of the dataset
tail(AnalysisTable)

#get general information on the dataset, head, tail and type of variables
str(AnalysisTable)

# get descriptive stats for continuous and categorical features
summary(AnalysisTable)

###################GRAPH FOR CONTINUOUS DATA############################

#histogram for showing the count in each bin

histo1 <- ggplot(AnalysisTable, aes(x = No_expected_students)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 
histo1
histo2 <- ggplot(AnalysisTable, aes(x = Average_clients)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 
histo2

histo3 <- ggplot(AnalysisTable, aes(x = Max_Client)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 
histo3


  
#plot all the histograms in one window

multiplot(histo1, histo2, histo3, cols=3)

#make the boxplot for continuous variable
  
box1 <- ggplot(AnalysisTable, aes(x = factor(0), y = No_expected_students)) + geom_boxplot() + xlab("Expected students") + scale_x_discrete(breaks = NULL) + coord_flip() + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 
box1

box2 <- ggplot(AnalysisTable, aes(x = factor(0), y = Average_clients)) + geom_boxplot() + xlab("Average counted students") + scale_x_discrete(breaks = NULL) + coord_flip() + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 
box2

box3 <- ggplot(AnalysisTable, aes(x = factor(0), y =  Max_Client)) + geom_boxplot() + xlab("Maximum counted students") + scale_x_discrete(breaks = NULL) + coord_flip() + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 
box3



#plot all the histograms in one window

multiplot(box1, box2, box3, cols=3)

############################GRAPH FOR CATEGORICAL DATA##################################

bar1 <- ggplot(AnalysisTable, aes(x = Room)) + geom_bar(fill="seagreen4")
bar1

bar2 <- ggplot(AnalysisTable, aes(x = Module)) + geom_bar(fill="seagreen4")
bar2

bar3 <- ggplot(AnalysisTable, aes(x = Tutorial)) + geom_bar(fill="seagreen4")
bar3

bar4 <- ggplot(AnalysisTable, aes(x = Double_module)) + geom_bar(fill="seagreen4")
bar4

bar5 <- ggplot(AnalysisTable, aes(x = Class_went_ahead)) + geom_bar(fill="seagreen4")
bar5

multiplot(bar1, bar2, cols=2)

#######RELETIONSHIP BETWEEN TARGET FEATURE AND CONTINOUS VARIABLE##############################

####CASE1: TARGET FEATURE IS CONTINUOUS

# Correlation Matrix
set.seed(42)
d = data.frame(x1=rnorm(100),
               x2=rnorm(100),
               x3=rnorm(100),
               x4=rnorm(100),
               x5=rnorm(100))

# estimated density in diagonal
ggpairs(d)

#bind all the continous variables I want to explore
Z <- cbind(AnalysisTable$ABUND, AnalysisTable$L.AREA, AnalysisTable$L.DIST,
           AnalysisTable$L.LDIST, AnalysisTable$YR.ISOL, AnalysisTable$ALT,
           LoynAnalysisTable$GRAZE)

#correlation of the variable
corvif

##CASE 2: TARGET FEATURE IS CATEGORICAL 

#Box plot
pairbox1 <- ggplot(AnalysisTable, aes(x = , y = )) + geom_boxplot() + coord_flip() + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

multiplot(pairbox1, pairbox2, cols=2)

#######RELETIONSHIP BETWEEN TARGET FEATURE AND CATEGORICAL VARIABLE##############################

##CASE 1: TARGET FEATURE IS CONTINUOUS

#Box plot
pairbox1 <- ggplot(AnalysisTable, aes(x = , y = )) + geom_boxplot() + coord_flip() + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

multiplot(pairbox1, pairbox2, cols=2)

##CASE 2: TARGET FEATURE IS CATEGORICAL 

ggplot(AnalysisTable, aes(x = Module, fill = factor(Room))) + geom_bar(position = "dodge")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))



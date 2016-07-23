
# <-------------------------------------- DATABASE --------------------------->
#In this section the connection with the database is made, database tables 
# are checked and the quiery to selected the data needed for the analysis is selected

#Library needed for carrying out the analyses

library(RMySQL) #package for communicate with MySQL database
library(ggplot2) #package for making graphs
library(GGally)
source("http://peterhaschke.com/Code/multiplot.R")


#set up connection for server
#connection <- dbConnect(MySQL(),user="student", password="goldilocks",dbname="who_there_db", host="localhost")
#connect from xamp
connection <- dbConnect(MySQL(),user="root", password="",dbname="mysql", host="localhost")

#get the list of tables present in the DB: dbListTables(nameOfConnection)
dbListTables(connection)

#show the field names for a given table: dbListFields(connection, table name).
dbListFields(connection, "Room")

#create the query
query <-"SELECT W.`Room_Room_id` as Room, W.`Date`, HOUR( W.Time ) as Time, T.`Module_Module_code` as Module, M.`Course_Level`,T.`Tutorial`, T.`Double_module`, T.`Class_went_ahead`, R.`Capacity`, G.`Percentage_room_full`, AVG(W.`Associated_client_counts`) as Average_clients, MAX(W.`Authenticated_client_counts`) as Max_clients FROM Room R, Wifi_log W, Ground_truth_data G, Time_table T, Module M WHERE W.Room_Room_id = R.Room_id AND G.Room_Room_id = W.Room_Room_id AND W.Date = G.Date AND HOUR( W.Time ) = HOUR( G.Time ) AND HOUR( W.Time ) = HOUR( T.Time_period ) AND T.Date = W.Date AND T.Room_Room_id = W.Room_Room_id AND M.`Module_code` = T.`Module_Module_code` GROUP BY W.Room_Room_id, HOUR( W.Time ) , W.Date"

# <--------------------------- EXPLORATORY ANALYSES --------------------------->
#select the data based on the query and store them in a dataframe called Analysis table
AnalysisTable <-dbGetQuery(connection, query)

# <--------------------------- DATA QUALITY REPORT --------------------------->
#get the dimension of the datasets
dim (AnalysisTable)

#get the first six rows of the dataset (by default)
head(AnalysisTable)

#get the last six rows of the dataset
tail(AnalysisTable)

#create the new column for getting number of people counted through ground truthe data
AnalysisTable$Counted_client <- AnalysisTable$Capacity * AnalysisTable$Percentage_room_full

#bin percentage_room_full into a categorical variable
AnalysisTable$Binned_Percentage <-cut(AnalysisTable$Percentage_room_full, breaks = 4, right=FALSE, labels=c('Low','Mid_Low','Mid_High', 'High'))

#bin time into a categorical variable for checking time of the day
AnalysisTable$Binned_Time <-cut(AnalysisTable$Time, breaks = 2, right=FALSE, labels=c('Morning','Afternoon'))


#get general information on the dataset, head, tail and type of variables
str(AnalysisTable)

#specifiy as factor: Module, Course_levels, Tutorial, Double Module and Class went ahead
#AnalysisTable$Module <- factor(AnalysisTable$Module)
AnalysisTable$Course_Level <- factor(AnalysisTable$Course_Level)
AnalysisTable$Tutorial <- factor(AnalysisTable$Tutorial)
AnalysisTable$Double_module <- factor(AnalysisTable$Double_module)
AnalysisTable$Class_went_ahead <- factor(AnalysisTable$Class_went_ahead)

#checked if the changes went ahead
str(AnalysisTable)

# get descriptive stats for all the features and checks for NAN
summary(AnalysisTable)

###################GRAPH FOR CONTINUOUS DATA############################

#histogram for showing the count in each bin

histo1 <- ggplot(AnalysisTable, aes(x = Max_clients)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

histo2 <- ggplot(AnalysisTable, aes(x = Average_clients)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 


histo3 <- ggplot(AnalysisTable, aes(x = Counted_client)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

histo4 <- ggplot(AnalysisTable, aes(x = Time)) + geom_histogram(binwidth = 2,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#plot all the histograms in one window

multiplot(histo1, histo2, histo3, histo4, cols=2)

#make the boxplot for continuous variable
  
box1 <- ggplot(AnalysisTable, aes(x = factor(0), y = Counted_client)) + geom_boxplot() + xlab("Expected students") + scale_x_discrete(breaks = NULL) + coord_flip() + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

box2 <- ggplot(AnalysisTable, aes(x = factor(0), y = Average_clients)) + geom_boxplot() + xlab("Average counted students") + scale_x_discrete(breaks = NULL) + coord_flip() + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

box3 <- ggplot(AnalysisTable, aes(x = factor(0), y =Max_clients)) + geom_boxplot() + xlab("Maximum counted students") + scale_x_discrete(breaks = NULL) + coord_flip() + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

box4 <- ggplot(AnalysisTable, aes(x = factor(0), y = Time)) + geom_boxplot() + xlab("Maximum counted students") + scale_x_discrete(breaks = NULL) + coord_flip() + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#plot all the histograms in one window
multiplot(box1, box2, box3, box4, cols=2)

############################GRAPH FOR CATEGORICAL DATA##################################

bar1 <- ggplot(AnalysisTable, aes(x = Room)) + geom_bar(fill="seagreen4")+ theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

bar2 <- ggplot(AnalysisTable, aes(x = Course_Level)) + geom_bar(fill="seagreen4")+ theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

bar3 <- ggplot(AnalysisTable, aes(x = Binned_Percentage)) + geom_bar(fill="seagreen4")+ theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

bar4 <- ggplot(AnalysisTable, aes(x = Binned_Time)) + geom_bar(fill="seagreen4")+ theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#bar2 <- ggplot(AnalysisTable, aes(x = Module)) + geom_bar(fill="seagreen4")
#bar3 <- ggplot(AnalysisTable, aes(x = Tutorial)) + geom_bar(fill="seagreen4")
#bar4 <- ggplot(AnalysisTable, aes(x = Double_module)) + geom_bar(fill="seagreen4")
#bar5 <- ggplot(AnalysisTable, aes(x = Class_went_ahead)) + geom_bar(fill="seagreen4

multiplot(bar1, bar2, bar3, bar4, cols=2)

#######RELETIONSHIP AMONG CONTINOUS VARIABLE##############################

####CASE1: TARGET FEATURE IS CONTINUOUS

# Correlation Matrix
ggpairs(AnalysisTable, columns = c('Counted_client','Max_clients', 'Average_clients', 'Time'))+ theme_bw()



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



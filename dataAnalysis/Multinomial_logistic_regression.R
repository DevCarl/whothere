# <-------------------------------------- DATABASE --------------------------->
#In this section the connection with the database is made, database tables 
# are checked and the quiery to selected the data needed for the analysis is selected

#Library needed for carrying out the analyses

library(RMySQL) #package for communicate with MySQL database
library(ggplot2) #package for making graphs
library(nnet)#package for running multinomial regression
library(caret)#for k-fold
source("http://peterhaschke.com/Code/multiplot.R") #for using multiplot

#<-----------------------------SELECT THE DATA FROM THE DATABASE ------------------------------>

#set up connection for server
#connection <- dbConnect(MySQL(),user="student", password="goldilocks",dbname="who_there_db", host="localhost")
#connect from xamp
connection <- dbConnect(MySQL(),user="root", password="",dbname="who_there_db", host="localhost")

#create the query
query <-"SELECT W.`Room_Room_id` as Room, W.`Date`, HOUR( W.Time ) as Time, T.`Module_Module_code` as Module, M.`Course_Level`,T.`Tutorial`, T.`Double_module`, T.`Class_went_ahead`, R.`Capacity`, G.`Percentage_room_full`, AVG(W.`Associated_client_counts`) as Wifi_Average_clients, MAX(W.`Authenticated_client_counts`) as Wifi_Max_clients FROM Room R, Wifi_log W, Ground_truth_data G, Time_table T, Module M WHERE W.Room_Room_id = R.Room_id AND G.Room_Room_id = W.Room_Room_id AND W.Date = G.Date AND HOUR( W.Time ) = HOUR( G.Time ) AND HOUR( W.Time ) = HOUR( T.Time_period ) AND T.Date = W.Date AND T.Room_Room_id = W.Room_Room_id AND M.`Module_code` = T.`Module_Module_code` GROUP BY W.Room_Room_id, HOUR( W.Time ) , W.Date"

#select the data based on the query and store them in a dataframe called Analysis table
AnalysisTable <-dbGetQuery(connection, query)

# <--------------------------- EXPLORATORY ANALYSES --------------------------->
#bin percentage_room_full into a categorical variable
AnalysisTable$Binned_Occupancy <-cut(AnalysisTable$Percentage_room_full, breaks = 4, right=FALSE, labels=c('Low','Mid_Low','Mid_High', 'High'))


#bin time into a categorical variable for checking time of the day
AnalysisTable$Factor_Time <-cut(AnalysisTable$Time, breaks = 4, right=FALSE, labels=c('Early Morning','Late Morning','Early Afternoon','Late Afternoon' ))


#get general information on the dataset, head, tail and type of variables
str(AnalysisTable)

#specifiy as factor: Module, Course_levels, Tutorial, Double Module and Class went ahead
AnalysisTable$Room <- factor(AnalysisTable$Room)
AnalysisTable$Course_Level <- factor(AnalysisTable$Course_Level)
AnalysisTable$Tutorial <- factor(AnalysisTable$Tutorial)
AnalysisTable$Double_module <- factor(AnalysisTable$Double_module)
AnalysisTable$Class_went_ahead <- factor(AnalysisTable$Class_went_ahead)

#checked if the changes went ahead
str(AnalysisTable)

# get descriptive stats for all the features and checks for NAN
summary(AnalysisTable)

###################GRAPHS FOR CONTINUOUS DATA############################

#histogram for showing the count in each bin for the Maximum number of clients
histo1 <- ggplot(AnalysisTable, aes(x = Wifi_Max_clients)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#histogram for showing the count in each bin for the Average number of clients
histo2 <- ggplot(AnalysisTable, aes(x = Wifi_Average_clients)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#histogram for showing the count in each bin for each hour of the day
histo3 <- ggplot(AnalysisTable, aes(x = Time)) + geom_histogram(binwidth = 2,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#plot all the histograms in one window
multiplot(histo1, histo2, histo3, cols=2)

#make the boxplot for continuous variable
#box plot for the counted client varable

#box plot for the counted clients variable
box1 <- ggplot(AnalysisTable, aes(x = factor(0), y = Wifi_Average_clients)) + geom_boxplot() + xlab("Average counted clients") + ylab("")+ scale_x_discrete(breaks = NULL)  + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#box plot for the maximum number of clients variable
box2 <- ggplot(AnalysisTable, aes(x = factor(0), y =Wifi_Max_clients)) + geom_boxplot() + xlab("Maximum counted clients") + ylab("")+ scale_x_discrete(breaks = NULL) + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#box plot for the Time continuous variable
box3 <- ggplot(AnalysisTable, aes(x = factor(0), y = Time)) + geom_boxplot() + xlab("Time") + ylab("")+ scale_x_discrete(breaks = NULL) + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 
#plot all the boxplots in one window
multiplot(box1, box2, box3, cols=2)


############################GRAPH FOR CATEGORICAL DATA##################################
#bar plot for the categorical variable: Room
bar1 <- ggplot(AnalysisTable, aes(x =Binned_Occupancy)) + geom_bar(fill="orangered2")+ theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#bar plot for the categorical variable: Room
bar2 <- ggplot(AnalysisTable, aes(x = Room)) + geom_bar(fill="orangered2")+ theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#bar plot for the categorical variable: Course level
bar3 <- ggplot(AnalysisTable, aes(x = Course_Level)) + geom_bar(fill="orangered2")+ theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#bar plot for the categorical variable: Time as factor
bar4 <- ggplot(AnalysisTable, aes(x = Factor_Time)) + geom_bar(fill="orangered2")+ theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#plot all the barplots in one window
multiplot(bar1, bar2, bar3, bar4, cols=2)

#<------------------------LOOKING AT THE FEATURES  FOR MULTINOMIAL LOGISTIC MODEL--------------->

##TARGET FEATURE = Binary_Percentage
#--> Relationship with continous variables

#Box plot

pairbox1 <- ggplot(AnalysisTable, aes(x = Binned_Occupancy, y =Wifi_Average_clients)) + geom_boxplot()+ theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

pairbox2 <- ggplot(AnalysisTable, aes(x = Binned_Occupancy, y = Wifi_Max_clients)) + geom_boxplot() + theme_bw()+theme( panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

pairbox3 <- ggplot(AnalysisTable, aes(x =Binned_Occupancy, y = Time )) + geom_boxplot() + theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

multiplot(pairbox1, pairbox2, pairbox3, cols=3)

## Barplots 

barpair1 <-ggplot(AnalysisTable, aes(x = Room, fill = Binned_Occupancy)) + geom_bar(position = "dodge")+ scale_fill_manual(values=c( "darkblue","cyan4","orange", "yellow"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

barpair2 <-ggplot(AnalysisTable, aes(x = Factor_Time, fill =Binned_Occupancy)) + geom_bar(position = "dodge")+ scale_fill_manual(values=c( "darkblue","cyan4","orange", "yellow"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

barpair3 <-ggplot(AnalysisTable, aes(x = Course_Level, fill = Binned_Occupancy)) + geom_bar(position = "dodge")+ scale_fill_manual(values=c( "darkblue","cyan4","orange", "yellow"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

multiplot(barpair1, barpair2, barpair3, cols=2)

#ANALYSIS
#CASE 1: AVG
#null model
totalAccuracy.null <- c()
cv <- 10
cvDivider <- floor(nrow(AnalysisTable)/(cv+1))

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  null <- multinom(Binned_Occupancy ~ 1, data=dataTrain,maxit=1000, trace = T)
  pred <- predict(null, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.null <- postResample(dataTest$Binned_Occupancy, pred)[[1]]
  print(paste('Current Accuracy for null model:',cv_ac.null,'for CV:',cv))
  totalAccuracy.null <- c(totalAccuracy.null, cv_ac.null)
}
mean(totalAccuracy.null)
#accuracy = 0.47

#avg model
totalAccuracy.avg <- c()
cv <- 10
cvDivider <- floor(nrow(AnalysisTable)/(cv+1))

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  avg <- multinom(Binned_Occupancy ~ Wifi_Average_logs, data=dataTrain,maxit=1000, trace = T)
  pred <- predict(avg, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.avg <- postResample(dataTest$Binned_Occupancy, pred)[[1]]
  print(paste('Current Accuracy for avg model:',cv_ac.avg,'for CV:',cv))
  totalAccuracy.avg <- c(totalAccuracy.avg, cv_ac.avg)
}
mean(totalAccuracy.avg)
#accuracy = 0.56

#avg.room model
totalAccuracy.avg.room <- c()
cv <- 10
cvDivider <- floor(nrow(AnalysisTable)/(cv+1))

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  avg.room <- multinom(Binned_Occupancy ~ Wifi_Average_logs+Room, data=dataTrain,maxit=1000, trace = T)
  pred <- predict(avg.room, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.avg.room <- postResample(dataTest$Binned_Occupancy, pred)[[1]]
  print(paste('Current Accuracy for avg model:',cv_ac.avg.room,'for CV:',cv))
  totalAccuracy.avg.room <- c(totalAccuracy.avg.room, cv_ac.avg.room)
}
mean(totalAccuracy.avg.room)
#accuracy = 0.58

#avg.time model
totalAccuracy.avg.time <- c()
cv <- 10
cvDivider <- floor(nrow(AnalysisTable)/(cv+1))

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  avg.time <- multinom(Binned_Occupancy ~ Wifi_Average_logs+Factor_Time, data=dataTrain,maxit=1000, trace = T)
  pred <- predict(avg.time, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.avg.time <- postResample(dataTest$Binned_Occupancy, pred)[[1]]
  print(paste('Current Accuracy for avg model:',cv_ac.avg.time,'for CV:',cv))
  totalAccuracy.avg.time <- c(totalAccuracy.avg.room, cv_ac.avg.time)
}
mean(totalAccuracy.avg.time)
#accuracy = 0.58

#avg.time model
totalAccuracy.avg.level <- c()
cv <- 10
cvDivider <- floor(nrow(AnalysisTable)/(cv+1))

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  avg.level <- multinom(Binned_Occupancy ~ Wifi_Average_logs+Course_level, data=dataTrain,maxit=1000, trace = T)
  pred <- predict(avg.time, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.avg.level <- postResample(dataTest$Binned_Occupancy, pred)[[1]]
  print(paste('Current Accuracy for avg model:',cv_ac.avg.level,'for CV:',cv))
  totalAccuracy.avg.level <- c(totalAccuracy.avg.level, cv_ac.avg.level)
}
mean(totalAccuracy.avg.time)
#accuracy = 0.58

#full model
for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  multinomfull <- multinom(Binned_Occupancy ~Wifi_Average_logs + Room + Factor_Time + Course_Level, data=dataTrain,maxit=1000, trace = T)
  pred <- predict(multinomfull, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac <- postResample(dataTest$Binned_Occupancy, pred)[[1]]
  print(paste('Current Accuracy for full model:',cv_ac,'for CV:',cv))
  totalAccuracy.fullModel <- c(totalAccuracy, cv_ac)
}





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

#specifiy as factor: Module, Course_Levels, Tutorial, Double Module and Class went ahead
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


set.seed(1000)
cv <- 10
cvDivider <- floor(nrow(AnalysisTable)/(cv+1))

#MULTINOMIAL REGRESSION
#null model
totalAccuracy.null <- c()
totalAIC.null <- c()
  
for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  null <- multinom(Binned_Occupancy ~ 1, data=dataTrain,maxit=1000, trace = T)
  pred.null <- predict(null, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.null <- postResample(dataTest$Binned_Occupancy, pred.null)[[1]]
  print(paste('Current Accuracy for null model:',cv_ac.null,'for CV:',cv))
  totalAccuracy.null <- c(totalAccuracy.null, cv_ac.null)
  #AIC
  print(paste('Current AIC:',AIC(null), 'for CV', cv))
  totalAIC.null <- c(totalAIC.null, AIC(null))
}

#CASE1: AVERAGE MODEL

#avg model
totalAccuracy.avg <- c()
totalAIC.avg <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  avg <- multinom(Binned_Occupancy ~ Wifi_Average_logs, data=dataTrain,maxit=1000, trace = T)
  pred.avg <- predict(avg, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.avg <- postResample(dataTest$Binned_Occupancy, pred.avg)[[1]]
  print(paste('Current Accuracy for avg model:',cv_ac.avg,'for CV:',cv))
  totalAccuracy.avg <- c(totalAccuracy.avg, cv_ac.avg)
  #AIC
  print(paste('Current AIC:',AIC(avg), 'for CV', cv))
  totalAIC.avg <- c(totalAIC.avg, AIC(avg))
}


#avg.room model
totalAccuracy.avg.room <- c()
totalAIC.avg.room <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  avg.room <- multinom(Binned_Occupancy ~ Wifi_Average_logs+Room, data=dataTrain,maxit=1000, trace = T)
  pred.avg.room <- predict(avg.room, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.avg.room <- postResample(dataTest$Binned_Occupancy, pred.avg.room)[[1]]
  print(paste('Current Accuracy for avg model:',cv_ac.avg.room,'for CV:',cv))
  totalAccuracy.avg.room <- c(totalAccuracy.avg.room, cv_ac.avg.room)
  #AIC
  print(paste('Current AIC:',AIC(avg.room), 'for CV', cv))
  totalAIC.avg.room <- c(totalAIC.avg.room, AIC(avg.room))
}


#avg.time model
totalAccuracy.avg.time <- c()
totalAIC.avg.time <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  avg.time <- multinom(Binned_Occupancy ~ Wifi_Average_logs+Factor_Time, data=dataTrain,maxit=1000, trace = T)
  pred.avg.time <- predict(avg.time, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.avg.time <- postResample(dataTest$Binned_Occupancy, pred.avg.time)[[1]]
  print(paste('Current Accuracy for avg model:',cv_ac.avg.time,'for CV:',cv))
  totalAccuracy.avg.time <- c(totalAccuracy.avg.time, cv_ac.avg.time)
  #AIC
  print(paste('Current AIC:',AIC(avg.time), 'for CV', cv))
  totalAIC.avg.time <- c(totalAIC.avg.time, AIC(avg.time))
}

#avg.level model
totalAccuracy.avg.level <- c()
totalAIC.avg.level <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  avg.level <- multinom(Binned_Occupancy ~ Wifi_Average_logs+ Course_Level, data=dataTrain,maxit=1000, trace = T)
  pred.avg.level <- predict(avg.level, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.avg.level <- postResample(dataTest$Binned_Occupancy, pred.avg.level)[[1]]
  print(paste('Current Accuracy for avg model:',cv_ac.avg.level,'for CV:',cv))
  totalAccuracy.avg.level <- c(totalAccuracy.avg.level, cv_ac.avg.level)
  
  #AIC
  print(paste('Current AIC:',AIC(avg.level), 'for CV', cv))
  totalAIC.avg.level <- c(totalAIC.avg.level, AIC(avg.level))
}

#avg.room.time model
totalAccuracy.avg.room.time <- c()
totalAIC.avg.room.time <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  avg.room.time <- multinom(Binned_Occupancy ~ Wifi_Average_logs+Room+Factor_Time, data=dataTrain,maxit=1000, trace = T)
  pred.avg.room.time <- predict(avg.room.time, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.avg.room.time <- postResample(dataTest$Binned_Occupancy, pred.avg.room.time)[[1]]
  print(paste('Current Accuracy for avg model:',cv_ac.avg.room.time,'for CV:',cv))
  totalAccuracy.avg.room.time<- c(totalAccuracy.avg.room.time, cv_ac.avg.room.time)
  
  #AIC
  print(paste('Current AIC:',AIC(avg.room.time), 'for CV', cv))
  totalAIC.avg.room.time <- c(totalAIC.avg.room.time, AIC(avg.room.time))
}

#avg.room.level model
totalAccuracy.avg.room.level <- c()
totalAIC.avg.room.level <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  avg.room.level <- multinom(Binned_Occupancy ~ Wifi_Average_logs+Room+Course_Level, data=dataTrain,maxit=1000, trace = T)
  pred.avg.room.level <- predict(avg.room.level, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.avg.room.level <- postResample(dataTest$Binned_Occupancy, pred.avg.room.level)[[1]]
  print(paste('Current Accuracy for avg model:',cv_ac.avg.room.level,'for CV:',cv))
  totalAccuracy.avg.room.level<- c(totalAccuracy.avg.room.level, cv_ac.avg.room.level)
  
  #AIC
  print(paste('Current AIC:',AIC(avg.room.level), 'for CV', cv))
  totalAIC.avg.room.level <- c(totalAIC.avg.room.level, AIC(avg.room.level))
}

#avg.time.level model
totalAccuracy.avg.time.level <- c()
totalAIC.avg.time.level <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  avg.time.level <- multinom(Binned_Occupancy ~ Wifi_Average_logs+Factor_Time+Course_Level, data=dataTrain,maxit=1000, trace = T)
  pred.avg.time.level <- predict(avg.time.level, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.avg.time.level <- postResample(dataTest$Binned_Occupancy, pred.avg.time.level)[[1]]
  print(paste('Current Accuracy for avg model:',cv_ac.avg.time.level,'for CV:',cv))
  totalAccuracy.avg.time.level<- c(totalAccuracy.avg.time.level, cv_ac.avg.time.level)
  
  #AIC
  print(paste('Current AIC:',AIC(avg.time.level), 'for CV', cv))
  totalAIC.avg.time.level <- c(totalAIC.avg.time.level, AIC(avg.time.level))
}

#full model
totalAccuracy.avg.full <- c()
totalAIC.avg.full <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  avg.full <- multinom(Binned_Occupancy ~Wifi_Average_logs + Room + Factor_Time + Course_Level, data=dataTrain,maxit=1000, trace = T)
  pred.avg.full <- predict(avg.full, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.avg.full <- postResample(dataTest$Binned_Occupancy, pred.avg.full)[[1]]
  print(paste('Current Accuracy for full model:',cv_ac.avg.full,'for CV:',cv))
  totalAccuracy.avg.full <- c(totalAccuracy.avg.full, cv_ac.avg.full)
  
  #AIC
  print(paste('Current AIC:',AIC(avg.full), 'for CV', cv))
  totalAIC.avg.full <- c(totalAIC.avg.full, AIC(avg.full))
}

#ACCURACIES
#NULL MODEL
print(paste('The accuracy for null model is:',mean(totalAccuracy.null),' and the AIC is:',mean(totalAIC.null)))
#AVG MODEL
print(paste('The accuracy for avg model is:',mean(totalAccuracy.avg),' and the AIC is:',mean(totalAIC.avg)))
#AVG.ROOM
print(paste('The accuracy for avg.room model is:',mean(totalAccuracy.avg.room),' and the AIC is:',mean(totalAIC.avg.room)))
#AVG.TIME
print(paste('The accuracy for avg.time model is:',mean(totalAccuracy.avg.time),' and the AIC is:',mean(totalAIC.avg.time)))
#AVG.LEVEL
print(paste('The accuracy for avg.level model is:',mean(totalAccuracy.avg.time),' and the AIC is:',mean(totalAIC.avg.time)))
#AVG.ROOM.TIME
print(paste('The accuracy for avg.room.time model is:',mean(totalAccuracy.avg.room.time),' and the AIC is:',mean(totalAIC.avg.room.time)))
#AVG.ROOM.LEVEL
print(paste('The accuracy for avg.room.level model is:',mean(totalAccuracy.avg.room.level),' and the AIC is:',mean(totalAIC.avg.room.level)))
#AVG.TIME.LEVEL
print(paste('The accuracy for avg.time.level model is:',mean(totalAccuracy.avg.time.level),' and the AIC is:',mean(totalAIC.avg.time.level)))
#AVG.FULL
print(paste('The accuracy for avg.full model is:',mean(totalAccuracy.avg.full),' and the AIC is:',mean(totalAIC.avg.full)))

#The best model in term of accuracy and AIC was AVG.ROOM with acc = 0.58  and AIC is: 364

#CASE2: MAX MODELS

#max model
totalAccuracy.max <- c()
totalAIC.max <- c()
for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  max <- multinom(Binned_Occupancy ~ Wifi_Max_logs, data=dataTrain,maxit=1000, trace = T)
  pred.max <- predict(max, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.max <- postResample(dataTest$Binned_Occupancy, pred.max)[[1]]
  print(paste('Current Accuracy for max model:',cv_ac.max,'for CV:',cv))
  totalAccuracy.max <- c(totalAccuracy.max, cv_ac.max)
  #AIC
  print(paste('Current AIC:',AIC(max), 'for CV', cv))
  totalAIC.max <- c(totalAIC.max, AIC(max))
}

#max.room model
totalAccuracy.max.room <- c()
totalAIC.max.room <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  max.room <- multinom(Binned_Occupancy ~ Wifi_Max_logs+Room, data=dataTrain,maxit=1000, trace = T)
  pred.max.room <- predict(max.room, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.max.room <- postResample(dataTest$Binned_Occupancy, pred.max.room)[[1]]
  print(paste('Current Accuracy for max model:',cv_ac.max.room,'for CV:',cv))
  totalAccuracy.max.room <- c(totalAccuracy.max.room, cv_ac.max.room)
  
  #AIC
  print(paste('Current AIC:',AIC(max.room), 'for CV', cv))
  totalAIC.max.room <- c(totalAIC.max.room, AIC(max.room))
}

#max.time model
totalAccuracy.max.time <- c()
totalAIC.max.time <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  max.time <- multinom(Binned_Occupancy ~ Wifi_Max_logs+Factor_Time, data=dataTrain,maxit=1000, trace = T)
  pred.max.time <- predict(max.time, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.max.time <- postResample(dataTest$Binned_Occupancy, pred.max.time)[[1]]
  print(paste('Current Accuracy for max model:',cv_ac.max.time,'for CV:',cv))
  totalAccuracy.max.time <- c(totalAccuracy.max.time, cv_ac.max.time)
  
  #AIC
  print(paste('Current AIC:',AIC(max.time), 'for CV', cv))
  totalAIC.max.time <- c(totalAIC.max.time, AIC(max.time))
}

#max.level model
totalAccuracy.max.level <- c()
totalAIC.max.level <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  max.level <- multinom(Binned_Occupancy ~ Wifi_Max_logs+Course_Level, data=dataTrain,maxit=1000, trace = T)
  pred.max.level <- predict(max.level, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.max.level <- postResample(dataTest$Binned_Occupancy, pred.max.level)[[1]]
  print(paste('Current Accuracy for max model:',cv_ac.max.level,'for CV:',cv))
  totalAccuracy.max.level <- c(totalAccuracy.max.level, cv_ac.max.level)
  
  #AIC
  print(paste('Current AIC:',AIC(max.level), 'for CV', cv))
  totalAIC.max.level <- c(totalAIC.max.level, AIC(max.level))
}

#max.room.time model
totalAccuracy.max.room.time <- c()
totalAIC.max.room.time <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  max.room.time <- multinom(Binned_Occupancy ~ Wifi_Max_logs+Room+Factor_Time, data=dataTrain,maxit=1000, trace = T)
  pred.max.room.time <- predict(max.room.time, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.max.room.time <- postResample(dataTest$Binned_Occupancy, pred.max.room.time)[[1]]
  print(paste('Current Accuracy for max model:',cv_ac.max.room.time,'for CV:',cv))
  totalAccuracy.max.room.time<- c(totalAccuracy.max.room.time, cv_ac.max.room.time)
  
  #AIC
  print(paste('Current AIC:',AIC(max.room.time), 'for CV', cv))
  totalAIC.max.room.time <- c(totalAIC.max.room.time, AIC(max.room.time))
}

#max.room.level model
totalAccuracy.max.room.level <- c()
totalAIC.max.room.level <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  max.room.level <- multinom(Binned_Occupancy ~ Wifi_Max_logs+Room+Course_Level, data=dataTrain,maxit=1000, trace = T)
  pred.max.room.level <- predict(max.room.level, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.max.room.level <- postResample(dataTest$Binned_Occupancy, pred.max.room.level)[[1]]
  print(paste('Current Accuracy for max model:',cv_ac.max.room.level,'for CV:',cv))
  totalAccuracy.max.room.level<- c(totalAccuracy.max.room.level, cv_ac.max.room.level)
  
  #AIC
  print(paste('Current AIC:',AIC(max.room.level), 'for CV', cv))
  totalAIC.max.room.level <- c(totalAIC.max.room.level, AIC(max.room.level))
}

#max.time.level model
totalAccuracy.max.time.level <- c()
totalAIC.max.time.level <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  max.time.level <- multinom(Binned_Occupancy ~ Wifi_Max_logs+Factor_Time+Course_Level, data=dataTrain,maxit=1000, trace = T)
  pred.max.time.level <- predict(max.time.level, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.max.time.level <- postResample(dataTest$Binned_Occupancy, pred.max.time.level)[[1]]
  print(paste('Current Accuracy for max model:',cv_ac.max.time.level,'for CV:',cv))
  totalAccuracy.max.time.level<- c(totalAccuracy.max.time.level, cv_ac.max.time.level)
  
  #AIC
  print(paste('Current AIC:',AIC(max.time.level), 'for CV', cv))
  totalAIC.max.time.level <- c(totalAIC.max.time.level, AIC(max.time.level))
}

#full model
totalAccuracy.max.full <- c()
totalAIC.max.full <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  max.full <- multinom(Binned_Occupancy ~Wifi_Max_logs + Room + Factor_Time + Course_Level, data=dataTrain,maxit=1000, trace = T)
  pred.max.full <- predict(max.full, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.max.full <- postResample(dataTest$Binned_Occupancy, pred.max.full)[[1]]
  print(paste('Current Accuracy for full model:',cv_ac.max.full,'for CV:',cv))
  totalAccuracy.max.full <- c(totalAccuracy.max.full, cv_ac.max.full)
  
  #AIC
  print(paste('Current AIC:',AIC(max.full), 'for CV', cv))
  totalAIC.max.full <- c(totalAIC.max.full, AIC(max.full))
}

#ACCURACIES
#NULL MODEL
print(paste('The accuracy for null model is:',mean(totalAccuracy.null),' and the AIC is:',mean(totalAIC.null)))
#max MODEL
print(paste('The accuracy for max model is:',mean(totalAccuracy.max),' and the AIC is:',mean(totalAIC.max)))
#max.ROOM
print(paste('The accuracy for max.room model is:',mean(totalAccuracy.max.room),' and the AIC is:',mean(totalAIC.max.room)))
#max.TIME
print(paste('The accuracy for max.time model is:',mean(totalAccuracy.max.time),' and the AIC is:',mean(totalAIC.max.time)))
#max.LEVEL
print(paste('The accuracy for max.level model is:',mean(totalAccuracy.max.time),' and the AIC is:',mean(totalAIC.max.time)))
#max.ROOM.TIME
print(paste('The accuracy for max.room.time model is:',mean(totalAccuracy.max.room.time),' and the AIC is:',mean(totalAIC.max.room.time)))
#max.ROOM.LEVEL
print(paste('The accuracy for max.room.level model is:',mean(totalAccuracy.max.room.level),' and the AIC is:',mean(totalAIC.max.room.level)))
#max.TIME.LEVEL
print(paste('The accuracy for max.time.level model is:',mean(totalAccuracy.max.time.level),' and the AIC is:',mean(totalAIC.max.time.level)))
#max.FULL
print(paste('The accuracy for max.full model is:',mean(totalAccuracy.max.full),' and the AIC is:',mean(totalAIC.max.full)))

#The best model in term of accuracy and AIC was MAX.ROOM with acc = 0.55  and AIC is: 385.
#However the accuracy and the AIC of the AVG.ROOM model was better and we keep it as best model and we will run it on the whole dataset.

final.avg.room <- multinom(Binned_Occupancy ~ Wifi_Average_logs+Room, data=AnalysisTable,maxit=1000)

#EXAMINE THE MODEL (wrong)
#examine the changes in predicted probability associated with the 2 response features
dses <- data.frame(Binned_occupancy=AnalysisTable$Binned_Occupancy,Room=AnalysisTable$Room,Course_Level=AnalysisTable$Course_Level,Wifi_Average_logs = mean(AnalysisTable$Wifi_Average_logs))
predict(final.avg.room.level, newdata = dses, "probs")

## store the predicted probabilities for each value of ses and write
pp.write <- cbind(dses, predict(final.avg.room.level, newdata = dses, type = "probs", se = TRUE))

## calculate the mean probabilities within each level of room
by(pp.write[, 5:8], pp.write$Room, colMeans)

by(pp.write[, 5:8], pp.write$Course_Level, colMeans)

#ORDINAL REGRESSION
#null model
totalAccuracy.ord.null <- c()
totalAIC.ord.null <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.null <- polr(Binned_Occupancy ~ 1, data=dataTrain, Hess=TRUE)
  pred.ord.null <- predict(ord.null, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.null <- postResample(dataTest$Binned_Occupancy, pred.ord.null)[[1]]
  print(paste('Current Accuracy for ordinal null model:',cv_ac.null,'for CV:',cv))
  totalAccuracy.ord.null <- c(totalAccuracy.ord.null, cv_ac.ord.null)
  #AIC
  print(paste('Current AIC:',AIC(ord.null), 'for CV', cv))
  totalAIC.ord.null <- c(totalAIC.ord.null, AIC(ord.null))
}

#CASE1: AVERAGE MODEL

#ord.avg model
totalAccuracy.ord.avg <- c()
totalAIC.ord.avg <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.avg <- polr(Binned_Occupancy ~ Wifi_Average_logs, data=dataTrain,Hess=TRUE)
  pred.ord.avg <- predict(ord.avg, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.avg <- postResample(dataTest$Binned_Occupancy, pred.ord.avg)[[1]]
  print(paste('Current Accuracy for ordinal avg model:',cv_ac.ord.avg,'for CV:',cv))
  totalAccuracy.ord.avg <- c(totalAccuracy.ord.avg, cv_ac.ord.avg)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.avg), 'for CV', cv))
  totalAIC.ord.avg <- c(totalAIC.ord.avg, AIC(ord.avg))
}


#ord.avg.room model
totalAccuracy.ord.avg.room <- c()
totalAIC.ord.avg.room <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.avg.room <- polr(Binned_Occupancy ~ Wifi_Average_logs+Room, data=dataTrain,Hess=TRUE)
  pred.ord.avg.room <- predict(ord.avg.room, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.avg.room <- postResample(dataTest$Binned_Occupancy, pred.ord.avg.room)[[1]]
  print(paste('Current Accuracy for ordinal avg room model:',cv_ac.ord.avg.room,'for CV:',cv))
  totalAccuracy.ord.avg.room <- c(totalAccuracy.ord.avg.room, cv_ac.ord.avg.room)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.avg.room), 'for CV', cv))
  totalAIC.ord.avg.room <- c(totalAIC.ord.avg.room, AIC(ord.avg.room))
}

#ord.avg.time model
totalAccuracy.ord.avg.time <- c()
totalAIC.ord.avg.time <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.avg.time <- polr(Binned_Occupancy ~ Wifi_Average_logs+Factor_Time, data=dataTrain,Hess=TRUE)
  pred.ord.avg.time <- predict(ord.avg.time, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.avg.time <- postResample(dataTest$Binned_Occupancy, pred.ord.avg.time)[[1]]
  print(paste('Current Accuracy for avg model:',cv_ac.ord.avg.time,'for CV:',cv))
  totalAccuracy.ord.avg.time <- c(totalAccuracy.ord.avg.time, cv_ac.ord.avg.time)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.avg.time), 'for CV', cv))
  totalAIC.ord.avg.time <- c(totalAIC.ord.avg.time, AIC(ord.avg.time))
}

#ord.avg.level model
totalAccuracy.ord.avg.level <- c()
totalAIC.ord.avg.level <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.avg.level <- polr(Binned_Occupancy ~ Wifi_Average_logs+ Course_Level, data=dataTrain,Hess=TRUE)
  pred.ord.avg.level <- predict(ord.avg.level, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.avg.level <- postResample(dataTest$Binned_Occupancy, pred.ord.avg.level)[[1]]
  print(paste('Current Accuracy for ord.ord.avg model:',cv_ac.ord.avg.level,'for CV:',cv))
  totalAccuracy.ord.avg.level <- c(totalAccuracy.ord.avg.level, cv_ac.ord.avg.level)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.avg.level), 'for CV', cv))
  totalAIC.ord.avg.level <- c(totalAIC.ord.avg.level, AIC(ord.avg.level))
}

#ord.avg.room.time model
totalAccuracy.ord.avg.room.time <- c()
totalAIC.ord.avg.room.time <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.avg.room.time <- polr(Binned_Occupancy ~ Wifi_Average_logs+Room+Factor_Time, data=dataTrain,Hess=TRUE)
  pred.ord.avg.room.time <- predict(ord.avg.room.time, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.avg.room.time <- postResample(dataTest$Binned_Occupancy, pred.ord.avg.room.time)[[1]]
  print(paste('Current Accuracy for ord.ord.avg model:',cv_ac.ord.avg.room.time,'for CV:',cv))
  totalAccuracy.ord.avg.room.time<- c(totalAccuracy.ord.avg.room.time, cv_ac.ord.avg.room.time)
  #AIC
  print(paste('Current AIC:',AIC(ord.avg.room.time), 'for CV', cv))
  totalAIC.ord.avg.room.time <- c(totalAIC.ord.avg.room.time, AIC(ord.avg.room.time))
}

#ord.avg.room.level model
totalAccuracy.ord.avg.room.level <- c()
totalAIC.ord.avg.room.level <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.avg.room.level <- polr(Binned_Occupancy ~ Wifi_Average_logs+Room+Course_Level, data=dataTrain,Hess=TRUE)
  pred.ord.avg.room.level <- predict(ord.avg.room.level, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.avg.room.level <- postResample(dataTest$Binned_Occupancy, pred.ord.avg.room.level)[[1]]
  print(paste('Current Accuracy for ord.ord.avg model:',cv_ac.ord.avg.room.level,'for CV:',cv))
  totalAccuracy.ord.avg.room.level<- c(totalAccuracy.ord.avg.room.level, cv_ac.ord.avg.room.level)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.avg.room.level), 'for CV', cv))
  totalAIC.ord.avg.room.level <- c(totalAIC.ord.avg.room.level, AIC(ord.avg.room.level))
}

#ord.avg.time.level model
totalAccuracy.ord.avg.time.level <- c()
totalAIC.ord.avg.time.level <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.avg.time.level <- polr(Binned_Occupancy ~ Wifi_Average_logs+Factor_Time+Course_Level, data=dataTrain,Hess=TRUE)
  pred.ord.avg.time.level <- predict(ord.avg.time.level, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.avg.time.level <- postResample(dataTest$Binned_Occupancy, pred.ord.avg.time.level)[[1]]
  print(paste('Current Accuracy for ord.ord.avg model:',cv_ac.ord.avg.time.level,'for CV:',cv))
  totalAccuracy.ord.avg.time.level<- c(totalAccuracy.ord.avg.time.level, cv_ac.ord.avg.time.level)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.avg.time.level), 'for CV', cv))
  totalAIC.ord.avg.time.level <- c(totalAIC.ord.avg.time.level, AIC(ord.avg.time.level))
}

#full model
totalAccuracy.ord.avg.full <- c()
totalAIC.ord.avg.full <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.avg.full <- polr(Binned_Occupancy ~Wifi_Average_logs + Room + Factor_Time + Course_Level, data=dataTrain,Hess=TRUE)
  pred.ord.avg.full <- predict(ord.avg.full, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.avg.full <- postResample(dataTest$Binned_Occupancy, pred.ord.avg.full)[[1]]
  print(paste('Current Accuracy for full model:',cv_ac.ord.avg.full,'for CV:',cv))
  totalAccuracy.ord.avg.full <- c(totalAccuracy.ord.avg.full, cv_ac.ord.avg.full)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.avg.full), 'for CV', cv))
  totalAIC.ord.avg.full <- c(totalAIC.ord.avg.full, AIC(ord.avg.full))
}

#ACCURACIES
#NULL MODEL
print(paste('The accuracy for null model is:',mean(totalAccuracy.null),' and the AIC is:',mean(totalAIC.null)))
#AVG MODEL
print(paste('The accuracy for ord.avg model is:',mean(totalAccuracy.ord.avg),' and the AIC is:',mean(totalAIC.ord.avg)))
#ord.avg.ROOM
print(paste('The accuracy for ord.avg.room model is:',mean(totalAccuracy.ord.avg.room),' and the AIC is:',mean(totalAIC.ord.avg.room)))
#ord.avg.TIME
print(paste('The accuracy for ord.avg.time model is:',mean(totalAccuracy.ord.avg.time),' and the AIC is:',mean(totalAIC.ord.avg.time)))
#ord.avg.LEVEL
print(paste('The accuracy for ord.avg.level model is:',mean(totalAccuracy.ord.avg.time),' and the AIC is:',mean(totalAIC.ord.avg.time)))
#ord.avg.ROOM.TIME
print(paste('The accuracy for ord.avg.room.time model is:',mean(totalAccuracy.ord.avg.room.time),' and the AIC is:',mean(totalAIC.ord.avg.room.time)))
#ord.avg.ROOM.LEVEL
print(paste('The accuracy for ord.avg.room.level model is:',mean(totalAccuracy.ord.avg.room.level),' and the AIC is:',mean(totalAIC.ord.avg.room.level)))
#ord.avg.TIME.LEVEL
print(paste('The accuracy for ord.avg.time.level model is:',mean(totalAccuracy.ord.avg.time.level),' and the AIC is:',mean(totalAIC.ord.avg.time.level)))
#ord.avg.FULL
print(paste('The accuracy for ord.avg.full model is:',mean(totalAccuracy.ord.avg.full),' and the AIC is:',mean(totalAIC.ord.avg.full)))


#AVG.ROOM was the best model in term of AIC and accuracy --> acc= 0.575 and AIC = 377. The ordinal regression in this case did not improve the accuracy.

#CASE2: MAX MODELS

#max model
totalAccuracy.ord.max <- c()
totalAIC.ord.max <- c()
for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.max <- polr(Binned_Occupancy ~ Wifi_Max_logs, data=dataTrain,Hess=TRUE)
  pred.ord.max <- predict(ord.max, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.max <- postResample(dataTest$Binned_Occupancy, pred.ord.max)[[1]]
  print(paste('Current Accuracy for ord.max model:',cv_ac.ord.max,'for CV:',cv))
  totalAccuracy.ord.max <- c(totalAccuracy.ord.max, cv_ac.ord.max)
  #AIC
  print(paste('Current AIC:',AIC(ord.max), 'for CV', cv))
  totalAIC.ord.max <- c(totalAIC.ord.max, AIC(ord.max))
}


#ord.max.room model

totalAccuracy.ord.max.room <- c()
totalAIC.ord.max.room <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.max.room <- polr(Binned_Occupancy ~ Wifi_Max_logs+Room, data=dataTrain,Hess=TRUE)
  pred.ord.max.room <- predict(ord.max.room, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.max.room <- postResample(dataTest$Binned_Occupancy, pred.ord.max.room)[[1]]
  print(paste('Current Accuracy for ord.max model:',cv_ac.ord.max.room,'for CV:',cv))
  totalAccuracy.ord.max.room <- c(totalAccuracy.ord.max.room, cv_ac.ord.max.room)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.max.room), 'for CV', cv))
  totalAIC.ord.max.room <- c(totalAIC.ord.max.room, AIC(ord.max.room))
}


#ord.max.time model
totalAccuracy.ord.max.time <- c()
totalAIC.ord.max.time <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.max.time <- polr(Binned_Occupancy ~ Wifi_Max_logs+Factor_Time, data=dataTrain,Hess=TRUE)
  pred.ord.max.time <- predict(ord.max.time, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.max.time <- postResample(dataTest$Binned_Occupancy, pred.ord.max.time)[[1]]
  print(paste('Current Accuracy for ord.max model:',cv_ac.ord.max.time,'for CV:',cv))
  totalAccuracy.ord.max.time <- c(totalAccuracy.ord.max.time, cv_ac.ord.max.time)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.max.time), 'for CV', cv))
  totalAIC.ord.max.time <- c(totalAIC.ord.max.time, AIC(ord.max.time))
}


#ord.max.level model
totalAccuracy.ord.max.level <- c()
totalAIC.ord.max.level <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.max.level <- polr(Binned_Occupancy ~ Wifi_Max_logs+Course_Level, data=dataTrain,Hess=TRUE)
  pred.ord.max.level <- predict(ord.max.level, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.max.level <- postResample(dataTest$Binned_Occupancy, pred.ord.max.level)[[1]]
  print(paste('Current Accuracy for ord.max model:',cv_ac.ord.max.level,'for CV:',cv))
  totalAccuracy.ord.max.level <- c(totalAccuracy.ord.max.level, cv_ac.ord.max.level)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.max.level), 'for CV', cv))
  totalAIC.ord.max.level <- c(totalAIC.ord.max.level, AIC(ord.max.level))
}

#ord.max.room.time model
totalAccuracy.ord.max.room.time <- c()
totalAIC.ord.max.room.time <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.max.room.time <- polr(Binned_Occupancy ~ Wifi_Max_logs+Room+Factor_Time, data=dataTrain,Hess=TRUE)
  pred.ord.max.room.time <- predict(ord.max.room.time, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.max.room.time <- postResample(dataTest$Binned_Occupancy, pred.ord.max.room.time)[[1]]
  print(paste('Current Accuracy for ord.max model:',cv_ac.ord.max.room.time,'for CV:',cv))
  totalAccuracy.ord.max.room.time<- c(totalAccuracy.ord.max.room.time, cv_ac.ord.max.room.time)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.max.room.time), 'for CV', cv))
  totalAIC.ord.max.room.time <- c(totalAIC.ord.max.room.time, AIC(ord.max.room.time))
}


#ord.max.room.level model
totalAccuracy.ord.max.room.level <- c()
totalAIC.ord.max.room.level <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.max.room.level <- polr(Binned_Occupancy ~ Wifi_Max_logs+Room+Course_Level, data=dataTrain,Hess=TRUE)
  pred.ord.max.room.level <- predict(ord.max.room.level, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.max.room.level <- postResample(dataTest$Binned_Occupancy, pred.ord.max.room.level)[[1]]
  print(paste('Current Accuracy for ord.max model:',cv_ac.ord.max.room.level,'for CV:',cv))
  totalAccuracy.ord.max.room.level<- c(totalAccuracy.ord.max.room.level, cv_ac.ord.max.room.level)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.max.room.level), 'for CV', cv))
  totalAIC.ord.max.room.level <- c(totalAIC.ord.max.room.level, AIC(ord.max.room.level))
}

#ord.max.time.level model
totalAccuracy.ord.max.time.level <- c()
totalAIC.ord.max.time.level <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.max.time.level <- polr(Binned_Occupancy ~ Wifi_Max_logs+Factor_Time+Course_Level, data=dataTrain,Hess=TRUE)
  pred.ord.max.time.level <- predict(ord.max.time.level, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.max.time.level <- postResample(dataTest$Binned_Occupancy, pred.ord.max.time.level)[[1]]
  print(paste('Current Accuracy for ord.max model:',cv_ac.ord.max.time.level,'for CV:',cv))
  totalAccuracy.ord.max.time.level<- c(totalAccuracy.ord.max.time.level, cv_ac.ord.max.time.level)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.max.time.level), 'for CV', cv))
  totalAIC.ord.max.time.level <- c(totalAIC.ord.max.time.level, AIC(ord.max.time.level))
}

#full model
totalAccuracy.ord.max.full <- c()
totalAIC.ord.max.full <- c()

for (cv in seq(1:cv)) {
  # assign chunk to data test
  dataTestIndex <- c((cv * cvDivider):(cv * cvDivider + cvDivider))
  dataTest <- AnalysisTable[dataTestIndex,]
  # everything else to train
  dataTrain <- AnalysisTable[-dataTestIndex,]
  
  ord.max.full <- polr(Binned_Occupancy ~Wifi_Max_logs + Room + Factor_Time + Course_Level, data=dataTrain,Hess=TRUE)
  pred.ord.max.full <- predict(ord.max.full, newdata=dataTest, type="class")
  
  #  classification error
  cv_ac.ord.max.full <- postResample(dataTest$Binned_Occupancy, pred.ord.max.full)[[1]]
  print(paste('Current Accuracy for full model:',cv_ac.ord.max.full,'for CV:',cv))
  totalAccuracy.ord.max.full <- c(totalAccuracy.ord.max.full, cv_ac.ord.max.full)
  
  #AIC
  print(paste('Current AIC:',AIC(ord.max.full), 'for CV', cv))
  totalAIC.ord.max.full <- c(totalAIC.ord.max.full, AIC(ord.max.full))
}

#ACCURACIES
#NULL MODEL
print(paste('The accuracy for null model is:',mean(totalAccuracy.null),' and the AIC is:',mean(totalAIC.null)))
#max MODEL
print(paste('The accuracy for ord.max model is:',mean(totalAccuracy.ord.max),' and the AIC is:',mean(totalAIC.ord.max)))
#ord.max.ROOM
print(paste('The accuracy for ord.max.room model is:',mean(totalAccuracy.ord.max.room),' and the AIC is:',mean(totalAIC.ord.max.room)))
#ord.max.TIME
print(paste('The accuracy for ord.max.time model is:',mean(totalAccuracy.ord.max.time),' and the AIC is:',mean(totalAIC.ord.max.time)))
#ord.max.LEVEL
print(paste('The accuracy for ord.max.level model is:',mean(totalAccuracy.ord.max.time),' and the AIC is:',mean(totalAIC.ord.max.time)))
#ord.max.ROOM.TIME
print(paste('The accuracy for ord.max.room.time model is:',mean(totalAccuracy.ord.max.room.time),' and the AIC is:',mean(totalAIC.ord.max.room.time)))
#ord.max.ROOM.LEVEL
print(paste('The accuracy for ord.max.room.level model is:',mean(totalAccuracy.ord.max.room.level),' and the AIC is:',mean(totalAIC.ord.max.room.level)))
#ord.max.TIME.LEVEL
print(paste('The accuracy for ord.max.time.level model is:',mean(totalAccuracy.ord.max.time.level),' and the AIC is:',mean(totalAIC.ord.max.time.level)))
#ord.max.FULL
print(paste('The accuracy for ord.max.full model is:',mean(totalAccuracy.ord.max.full),' and the AIC is:',mean(totalAIC.ord.max.full)))

#The best model in term of AIC and accuracy was the max.room --> accuracy =0.57  and AIC is: 391

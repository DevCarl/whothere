# <-------------------------------------- DATABASE --------------------------->
#In this section the connection with the database is made, database tables 
# are checked and the quiery to selected the data needed for the analysis is selected

#Library needed for carrying out the analyses

library(RMySQL) #package for communicate with MySQL database
library(ggplot2) #package for making graphs
library(GGally)
library(nlme)
library(caret) # for splitting the database
library(DAAG)#for k-fold validation on linear and logistic
library(boot)#for k-fold validation on glm
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
#create the new column for getting number of people counted through ground truth data
AnalysisTable$Survey_counted_clients <- AnalysisTable$Capacity * AnalysisTable$Percentage_room_full

#bin time into a categorical variable for checking time of the day
AnalysisTable$Factor_Time <-cut(AnalysisTable$Time, breaks = 4, right=FALSE, labels=c('Early Morning','Late Morning','Early Afternoon','Late Afternoon' ))

#bin percentage_room_full into a binary variable
AnalysisTable$Binary_Occupancy[AnalysisTable$Percentage_room_full <= 0] <- "empty"
AnalysisTable$Binary_Occupancy[AnalysisTable$Percentage_room_full>0] <- "occupied"
AnalysisTable$Binary_Occupancy <- factor(AnalysisTable$Binary_Occupancy)

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

###################GRAPH FOR CONTINUOUS DATA############################

#Box plot

pairbox4 <- ggplot(AnalysisTable, aes(x = Binary_Percentage, y =Average_clients)) + geom_boxplot()+ theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

pairbox5 <- ggplot(AnalysisTable, aes(x = Binary_Percentage, y = Max_clients)) + geom_boxplot() + theme_bw()+theme( panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

pairbox6 <- ggplot(AnalysisTable, aes(x =Binary_Percentage, y = Time )) + geom_boxplot() + theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

multiplot(pairbox4, pairbox5, pairbox6, cols=3)

##CASE 2: TARGET FEATURE IS CATEGORICAL 



barpair1 <-ggplot(AnalysisTable, aes(x = Room, fill = Binary_Percentage)) + geom_bar(position = "dodge")+ scale_fill_manual(values=c( "cyan4","orange"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

barpair2 <-ggplot(AnalysisTable, aes(x = Binned_Time, fill = Binary_Percentage)) + geom_bar(position = "dodge")+ scale_fill_manual(values=c( "cyan4","orange"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

barpair3 <-ggplot(AnalysisTable, aes(x = Course_Level, fill = Binary_Percentage)) + geom_bar(position = "dodge")+ scale_fill_manual(values=c( "cyan4","orange"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))


multiplot(barpair1, barpair2, barpair3, cols=2)

Logitmodel1 <- glm(Binary_Percentage ~Max_clients + Room + Binned_Time + Course_Level ,family=binomial,data=train)
summary(Logitmodel1)
plot(Logitmodel1)


fitted.results <- predict(Logitmodel,test, type='response')
fitted.results1 <- ifelse(fitted.results > 0.5,'occupied','empty')

misClasificError <- mean(fitted.results1 != test$Binary_Percentage)
print(paste('Accuracy',1-misClasificError))

Logitmodel <- glm(Binary_Percentage ~Average_clients + Room + Binned_Time + Course_Level ,family=binomial,data=train)
summary(Logitmodel)

fitted.results <- predict(Logitmodel,test, type='response')
fitted.results1 <- ifelse(fitted.results > 0.5,'occupied','empty')

misClasificError <- mean(fitted.results1 != test$Binary_Percentage)
print(paste('Accuracy',1-misClasificError))


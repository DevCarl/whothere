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
library(plyr)
library(reshape2)
library(glmnet)
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

#<--------Exploring interactions---------------------->

#Graph exploring interactive effect between Wifi_Average_clients and Time on binary occupancy 
pair1 <- ggplot(AnalysisTable, aes(x = Factor_Time, y =Wifi_Average_clients, fill = factor(Binned_Occupancy))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4","orange", "yellow"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#Graph exploring interactive effect between Wifi_Average_clients and Course level on binary occupancy 
pair2 <- ggplot(AnalysisTable, aes(x = Course_Level, y =Wifi_Average_clients, fill = factor(Binned_Occupancy))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow", "orange", "blue", "red"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))
#Graph exploring interactive effect between Wifi_Max_clients and Time on binary occupancy
pair3 <- ggplot(AnalysisTable, aes(x = Factor_Time, y =Wifi_Max_clients, fill = factor(Binned_Occupancy))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4","orange", "yellow"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#Graph exploring interactive effect between Wifi_Max_clients and Course level on binary occupancy
pair4 <- ggplot(AnalysisTable, aes(x = Course_Level, y =Wifi_Max_clients, fill = factor(Binned_Occupancy))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow", "orange", "blue", "red"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#Graph exploring interactive effect between time and course level on binary occupancy 
pair5 <-ggplot(AnalysisTable, aes(x=Factor_Time, fill = factor(Course_Level)) ) + facet_grid(Binned_Occupancy ~ .) + geom_bar(position = "dodge")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow", "orange", "blue", "red"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

multiplot(pair1, pair2, pair3, pair4, cols=2)
pair5


#<--------------------k -Fold Cross-Validation --------------------------------->

##CASE 1: Multinomial logistic regression
formula <- as.formula(Binned_Occupancy ~Wifi_Average_clients + Factor_Time + Course_Level)
X <- model.matrix(formula, AnalysisTable)
model <- cv.glmnet(X, AnalysisTable$Binned_Occupancy, standardize=FALSE, family='multinomial',type.measure="mse")
model$mae

predicted_class<-predict(model, newx = X, s = "lambda.min", type = "class")
mean(as.character(predicted_class) != as.character(AnalysisTable$Binned_Occupancy))

mse.min1 <- model$cvm[model1$lambda == model$lambda.min]
plot(model)

##CASE 1:Ordinal logistic regression
library(MASS)
library(rms)
m <- polr(Binned_Occupancy ~Wifi_Average_clients + Factor_Time + Course_Level, data = AnalysisTable, Hess=TRUE)

cal <- calibrate(m, method = "cross validation", B=10) 



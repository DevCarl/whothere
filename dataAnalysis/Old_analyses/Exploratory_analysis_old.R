
# <-------------------------------------- DATABASE --------------------------->
#In this section the connection with the database is made, database tables 
# are checked and the quiery to selected the data needed for the analysis is selected

#Library needed for carrying out the analyses

library(RMySQL) #package for communicate with MySQL database
library(ggplot2) #package for making graphs
library(GGally)
library(nlme)
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
AnalysisTable$Binned_Time <-cut(AnalysisTable$Time, breaks = 4, right=FALSE, labels=c('Early Morning','Late Morning','Early Afternoon','Late Afternoon' ))


#get general information on the dataset, head, tail and type of variables
str(AnalysisTable)

#specifiy as factor: Module, Course_levels, Tutorial, Double Module and Class went ahead
#AnalysisTable$Module <- factor(AnalysisTable$Module)
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

#histogram for showing the count in each bin

histo1 <- ggplot(AnalysisTable, aes(x = Max_clients)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

histo2 <- ggplot(AnalysisTable, aes(x = Average_clients)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 


histo3 <- ggplot(AnalysisTable, aes(x = Counted_client)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

histo4 <- ggplot(AnalysisTable, aes(x = Time)) + geom_histogram(binwidth = 2,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#plot all the histograms in one window

multiplot(histo1, histo2, histo3, histo4, cols=2)

#make the boxplot for continuous variable
  
box1 <- ggplot(AnalysisTable, aes(x = factor(0), y = Counted_client)) + geom_boxplot() + xlab("") + scale_x_discrete(breaks = NULL) + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

box2 <- ggplot(AnalysisTable, aes(x = factor(0), y = Average_clients)) + geom_boxplot() + xlab("") + scale_x_discrete(breaks = NULL) +  theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

box3 <- ggplot(AnalysisTable, aes(x = factor(0), y =Max_clients)) + geom_boxplot() + xlab("") + scale_x_discrete(breaks = NULL) +  theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

box4 <- ggplot(AnalysisTable, aes(x = factor(0), y = Time)) + geom_boxplot() + xlab("") + scale_x_discrete(breaks = NULL) +  theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

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

#######RELATIONSHIP BETWEEN Variables #############################

##CASE 1: TARGET FEATURE = Counted_clients 
#--> Relationship with continous variables

# Correlation Matrix
ggpairs(AnalysisTable, columns = c('Counted_client','Max_clients', 'Average_clients', 'Time'))+ geom_point() +  geom_smooth(method=lm, fill="blue", color="blue", ...)

my_fn <- function(data, mapping, ...){
  p <- ggplot(data = data, mapping = mapping) + 
    geom_point() + 
    geom_smooth(method=lm, fill="orangered3", color="orangered3", ...)
  p
}

ggpairs(AnalysisTable, columns = c('Counted_client','Max_clients', 'Average_clients', 'Time'), lower = list(continuous = my_fn)) + theme_bw()

#--> Relationship with categorical variables

#Box plot
pairbox1 <- ggplot(AnalysisTable, aes(x = Room, y =Counted_client)) + geom_boxplot()+ theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

pairbox2 <- ggplot(AnalysisTable, aes(x = Binned_Time , y = Counted_client)) + geom_boxplot() + theme_bw()+theme( panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

pairbox3 <- ggplot(AnalysisTable, aes(x = Course_Level , y = Counted_client )) + geom_boxplot() + theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 


multiplot(pairbox1, pairbox2, pairbox3, cols=3)

#######RELETIONSHIP BETWEEN TARGET FEATURE AND CATEGORICAL VARIABLE##############################

##CASE 1: TARGET FEATURE = Counted_clients

#Box plot

pairbox4 <- ggplot(AnalysisTable, aes(x = Binned_Capacity, y =Average_clients)) + geom_boxplot()+ theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

pairbox5 <- ggplot(AnalysisTable, aes(x = Binned_Capacity, y = Max_clients)) + geom_boxplot() + theme_bw()+theme( panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

pairbox6 <- ggplot(AnalysisTable, aes(x =Binned_Capacity, y = Time )) + geom_boxplot() + theme_bw()+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

multiplot(pairbox4, pairbox5, pairbox6, cols=3)

##CASE 2: TARGET FEATURE IS CATEGORICAL 

barpair1 <- ggplot(AnalysisTable, aes(x = Binned_Percentage, fill = Room)) + geom_bar(position = "dodge")+ scale_fill_manual(values=c( "cyan4","yellow","orange"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

barpair2 <- ggplot(AnalysisTable, aes(x = Binned_Percentage, fill = Binned_Time)) + geom_bar(position = "dodge")+ scale_fill_manual(values=c("blue", "cyan4","yellow","orange"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

barpair3 <- ggplot(AnalysisTable, aes(x = Binned_Percentage, fill = Course_Level)) + geom_bar(position = "dodge")+ scale_fill_manual(values=c( "darkblue","blue","cyan4","yellow","orange"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

multiplot(barpair1, barpair2, barpair3, cols=3)

ggplot(cabbage_exp, aes(x=Date, y=Weight, fill=Cultivar)) + 
  geom_bar(position='dodge', stat='identity')

ggplot(AnalysisTable, aes(x = Binned_Percentage, y =Counted_client, fill = Room)) + geom_bar(position = "dodge", stat='identity')+ scale_fill_manual(values=c( "cyan4","yellow","orange"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

occupancy.lm = lm(Counted_client ~ Max_clients + Room + Binned_Time + Course_Level + Course_Level * Max_clients + Binned_Time*Course_Level, data=AnalysisTable)
summary(occupancy.lm)
plot(occupancy.lm)



plot(occupancy.lm, which = c(1), col = 1, add.smooth = FALSE, caption)

plot(AnalysisTable$Max_clients, resid(occupancy.lm), xlab = "Max_clients", ylab = "Residuals")
plot(AnalysisTable$Room, resid(occupancy.lm), xlab = "Room", ylab = "Residuals")
plot(AnalysisTable$Binned_Time, resid(occupancy.lm), xlab = "Binned_Time", ylab = "Residuals")
plot(AnalysisTable$Course_Level, resid(occupancy.lm), xlab = "Course_Level", ylab = "Residuals")


#Trellis
qplot(Average_clients, Counted_client, data = AnalysisTable, facets = . ~ Room) + geom_smooth(method=lm, fill="orangered3", color="orangered3")

qplot(Average_clients, Counted_client, data = AnalysisTable, facets = . ~ Binned_Time) + geom_smooth(method=lm, fill="orangered3", color="orangered3")

qplot(Average_clients, Counted_client, data = AnalysisTable, facets = . ~ Course_Level) + geom_smooth(method=lm, fill="orangered3", color="orangered3")

qplot(Max_clients, Counted_client, data = AnalysisTable, facets = . ~ Room) + geom_smooth(method=lm, fill="orangered3", color="orangered3")

qplot(Max_clients, Counted_client, data = AnalysisTable, facets = . ~ Binned_Time) + geom_smooth(method=lm, fill="orangered3", color="orangered3")

qplot(Max_clients, Counted_client, data = AnalysisTable, facets = . ~ Course_Level) + geom_smooth(method=lm, fill="orangered3", color="orangered3")

# Bar plots
ggplot(AnalysisTable, aes(x = Binned_Time, y = Counted_client, fill = factor(Room))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

ggplot(AnalysisTable, aes(x = Course_Level, y = Counted_client, fill = factor(Room))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow", "orange", "blue"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

ggplot(AnalysisTable, aes(x = Binned_Time, y = Counted_client, fill = factor(Course_Level))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow", "orange", "blue"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

ggplot(AnalysisTable, aes(x = Binned_Time, y = Average_clients, fill = factor(Room))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow", "orange"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

ggplot(AnalysisTable, aes(x = Binned_Time, y = Average_clients, fill = factor(Course_Level))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow", "orange"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

ggplot(AnalysisTable, aes(x = Room, y = Average_clients, fill = factor(Course_Level))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow", "orange", "blue"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

# Linear Regression

occupancy.lm = lm(Counted_client ~ Max_clients + Room + Binned_Time + Course_Level + Course_Level * Max_clients + Binned_Time * Course_Level, data=AnalysisTable)
summary(occupancy.lm)
plot(occupancy.lm)

occupancy.glm = lm(Counted_client ~ Max_clients + Room + Binned_Time + Course_Level + Course_Level * Max_clients + Binned_Time * Course_Level, data=AnalysisTable)

# Glm with poisson distribution
occupancy.poisson1 = glm(Counted_client ~ Max_clients + Room + Binned_Time + Course_Level + Course_Level * Max_clients + Binned_Time * Course_Level, family = poisson, data=AnalysisTable)
summary(occupancy.poisson1)
plot(occupancy.poisson1)

occupancy.poisson2 = glm(Counted_client ~ Max_clients + Room + Binned_Time + Course_Level + Course_Level * Max_clients + Binned_Time * Course_Level, family = quasipoisson, data=AnalysisTable)
summary(occupancy.poisson2)
plot(occupancy.poisson2)



library(MASS)
occupancy.negbinomial <- glm.nb(Counted_client ~ Max_clients + Room + Binned_Time + Course_Level + Course_Level * Max_clients + Binned_Time * Course_Level, link = "log", data=AnalysisTable)

plot(occupancy.negbinomial)
warnings()


# Logistic Regression
library(nnet)

glm.fit=multinom(Binary_Percentage ~ Max_clients + Room + Binned_Time + Course_Level, family = binomial, data=AnalysisTable)
summary(glm.fit)
#Prediction
predict(glm.fit, AnalysisTable, "probs")




vf5 <- varExp(form =~ Max_clients)
M.gls5 <- gls(Counted_client ~ Max_clients + Room + Binned_Time + Course_Level + Course_Level * Max_clients + Binned_Time*Course_Level, weights = vf5, data=AnalysisTable)




vf1<- varFixed(~ Max_clients)
M.gls <- gls(Counted_client ~ Max_clients + Room + Course_Level , weights = vf1, data=AnalysisTable)


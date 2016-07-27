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


#for exploring tables present in the DB: dbListTables(nameOfConnection)
dbListTables(connection)

#for exploring field names for a given table: dbListFields(connection, table name).
dbListFields(connection, "Room")

#create the query
query <-"SELECT W.`Room_Room_id` as Room, W.`Date`, HOUR( W.Time ) as Time, T.`Module_Module_code` as Module, M.`Course_Level`,T.`Tutorial`, T.`Double_module`, T.`Class_went_ahead`, R.`Capacity`, G.`Percentage_room_full`, AVG(W.`Associated_client_counts`) as Wifi_Average_clients, MAX(W.`Authenticated_client_counts`) as Wifi_Max_clients FROM Room R, Wifi_log W, Ground_truth_data G, Time_table T, Module M WHERE W.Room_Room_id = R.Room_id AND G.Room_Room_id = W.Room_Room_id AND W.Date = G.Date AND HOUR( W.Time ) = HOUR( G.Time ) AND HOUR( W.Time ) = HOUR( T.Time_period ) AND T.Date = W.Date AND T.Room_Room_id = W.Room_Room_id AND M.`Module_code` = T.`Module_Module_code` GROUP BY W.Room_Room_id, HOUR( W.Time ) , W.Date"

#select the data based on the query and store them in a dataframe called Analysis table
AnalysisTable <-dbGetQuery(connection, query)

# <--------------------------- EXPLORATORY ANALYSES --------------------------->


# <--------------------------- DATA QUALITY REPORT --------------------------->
#get the dimension of the datasets
dim (AnalysisTable)

#get the first six rows of the dataset (by default)
head(AnalysisTable)

#get the last six rows of the dataset
tail(AnalysisTable)

#create the new column for getting number of people counted through ground truth data
AnalysisTable$Survey_counted_clients <- AnalysisTable$Capacity * AnalysisTable$Percentage_room_full

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

###################GRAPH FOR CONTINUOUS DATA############################


#histogram for showing the count in each bin for the Maximum number of clients
histo1 <- ggplot(AnalysisTable, aes(x = Wifi_Max_clients)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#histogram for showing the count in each bin for the Average number of clients
histo2 <- ggplot(AnalysisTable, aes(x = Wifi_Average_clients)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#histogram for showing the count in each bin for the number of clients counted with the survey
histo3 <- ggplot(AnalysisTable, aes(x = Survey_counted_clients)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#histogram for showing the count in each bin for each hour of the day
histo4 <- ggplot(AnalysisTable, aes(x = Time)) + geom_histogram(binwidth = 2,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#plot all the histograms in one window
multiplot(histo1, histo2, histo3, histo4, cols=2)

#box plot for the counted client varable
box1 <- ggplot(AnalysisTable, aes(x = factor(0), y = Survey_counted_clients)) + geom_boxplot() + xlab("Counted clients with the survey") + ylab("")+ scale_x_discrete(breaks = NULL) + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#box plot for the counted clients variable
box2 <- ggplot(AnalysisTable, aes(x = factor(0), y = Wifi_Average_clients)) + geom_boxplot() + xlab("Average Maximum counted students with Wifi") + ylab("")+ scale_x_discrete(breaks = NULL)  + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#box plot for the maximum number of clients variable
box3 <- ggplot(AnalysisTable, aes(x = factor(0), y =Wifi_Max_clients)) + geom_boxplot() + xlab("Maximum counted students with Wifi") + ylab("")+ scale_x_discrete(breaks = NULL) + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#box plot for the Time continuous variable
box4 <- ggplot(AnalysisTable, aes(x = factor(0), y = Time)) + geom_boxplot() + xlab("Maximum counted students") + ylab("")+ scale_x_discrete(breaks = NULL) + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#plot all the boxplots in one window
multiplot(box1, box2, box3, box4, cols=2)

############################GRAPH FOR CATEGORICAL DATA##################################

#bar plot for the categorical variable: Room
bar1 <- ggplot(AnalysisTable, aes(x = Room)) + geom_bar(fill="orangered2")+ theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#bar plot for the categorical variable: Course level
bar2 <- ggplot(AnalysisTable, aes(x = Course_Level)) + geom_bar(fill="orangered2")+ theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#bar plot for the categorical variable: Time as factor
bar3 <- ggplot(AnalysisTable, aes(x = Factor_Time)) + geom_bar(fill="orangered2")+ theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#plot all the barplots in one window
multiplot(bar1, bar2, bar3, cols=2)

#<---------------------------LOOKING AT THE FEATURES  FOR LINEAR MODEL----------------------->

##TARGET FEATURE = Counted_clients 

#--> Relationship with continous variables

# Correlation Matrix

my_fn <- function(data, mapping, ...){
  p <- ggplot(data = data, mapping = mapping) + 
    geom_point() + 
    geom_smooth(method=lm, fill="orangered3", color="orangered3", ...)
  p
}

ggpairs(AnalysisTable, columns = c('Survey_counted_clients','Wifi_Max_clients', 'Wifi_Average_clients', 'Time'), lower = list(continuous = my_fn)) + theme_bw()

#Counted  clients seems to have a good correlation with Avg and Max, therefore we are will try both the model. Time does not seems to be correlated and it seems more categorical.

#--> Relationship with categorical variables

#Box plot for exploring relationship between Room and Client count
pairbox1 <- ggplot(AnalysisTable, aes(x = Room, y =Counted_client)) + geom_boxplot() + theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#Box plot for exploring relationship between Room and time as a factor
pairbox2 <- ggplot(AnalysisTable, aes(x = Factor_Time, y =Counted_client)) + geom_boxplot() + theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#Box plot for exploring relationship between Room and course level
pairbox3 <- ggplot(AnalysisTable, aes(x = Course_Level, y =Counted_client)) + geom_boxplot()+  theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#plot all the boxplots in one window
multiplot(pairbox1, pairbox2, pairbox3, cols=3)


#EXPLORING INTERACTION

#<--- CASE 1: Average client --->

#Graph exploring interactive effect between Average clients and Room on counted client 
trellis1 <- qplot(Average_clients, Counted_client, data = AnalysisTable, facets = . ~ Room) + geom_smooth(method=lm, fill="orangered3", color="orangered3") + theme_bw()

#Graph exploring interactive effect between Average clients and Time counted client 
trellis2 <- qplot(Average_clients, Counted_client, data = AnalysisTable, facets = . ~ Factor_Time) + geom_smooth(method=lm, fill="orangered3", color="orangered3")+ theme_bw()

#Graph exploring interactive effect between Average clients and course level on counted client 
trellis3 <- qplot(Average_clients, Counted_client, data = AnalysisTable, facets = . ~ Course_Level) + geom_smooth(method=lm, fill="orangered3", color="orangered3")+ theme_bw()

#plot all the graphs on the interactive effect in one window
multiplot(trellis1, trellis2, trellis3, cols=3)

#<--- CASE 2: Maximum client --->

#Graph exploring interactive effect between Maximum clients and room on counted client 
trellis4 <-qplot(Max_clients, Counted_client, data = AnalysisTable, facets = . ~ Room) + geom_smooth(method=lm, fill="orangered3", color="orangered3")+ theme_bw()

#Graph exploring interactive effect between Maximum clients and time on counted client 
trellis5 <-qplot(Max_clients, Counted_client, data = AnalysisTable, facets = . ~ Factor_Time) + geom_smooth(method=lm, fill="orangered3", color="orangered3")+ theme_bw()

#Graph exploring interactive effect between Maximum clients and course level on counted client 
trellis6 <-qplot(Max_clients, Counted_client, data = AnalysisTable, facets = . ~ Course_Level) + geom_smooth(method=lm, fill="orangered3", color="orangered3")+ theme_bw()

#plot all the graphs on the interactive effect in one window
multiplot(trellis4, trellis5, trellis6, cols=3)

# Bar plots for exploring interactions with categorical variables 

#Graph exploring interactive effect between Time and Room on Counted client 
pair1 <- ggplot(AnalysisTable, aes(x = Factor_Time, y = Counted_client, fill = factor(Room))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#Graph exploring interactive effect between Course level and Room on Counted client 
pair2 <- ggplot(AnalysisTable, aes(x = Course_Level, y = Counted_client, fill = factor(Room))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow", "orange", "blue"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#Graph exploring interactive effect between Course level and Time on Counted client 
pair3 <-ggplot(AnalysisTable, aes(x = Factor_Time, y = Counted_client, fill = factor(Course_Level))) + geom_bar(position = "dodge", stat="identity")+ scale_fill_manual(values=c( "darkblue","cyan4", "yellow", "orange", "red"))+theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

multiplot(pair1, pair2, pair3, cols=3)


#<-----------------------The Validation Set Approach: training and test dataset ------------------->

#declaring the sample size for the training set as 60% of the whole dataset
smp_size <- floor(0.60 * nrow(AnalysisTable))

## set the seed to make your partition reproductible
set.seed(123)
#select the 60% of the dataset
train_ind <- sample(seq_len(nrow(AnalysisTable)), size = smp_size)

#creating the training set with the 60% of the observation selected before
train <-AnalysisTable[train_ind, ]
#creating the test set with rest of the obervation - 60% 
test <- AnalysisTable[-train_ind, ]

#N.B. In the next version replace this method with k-Fold Cross-Validation, because more robust

#<--------------------------- LINEAR REGRESSION ------------------------>

#CASE 1: Linear regression with Max Clients
occupancy.lm.max = lm(Counted_client ~ Max_clients + Room + Factor_Time + Course_Level + Course_Level * Max_clients + Factor_Time * Course_Level, data=train)
#print the summary of the model
summary(occupancy.lm.max)
#plot the residual
plot(occupancy.lm.max)
#Calculation of the Root Mean Square Error for getting the accuracy of the model on the training 
mean(residuals(occupancy.lm.max)^2)
sqrt(mean(residuals(occupancy.lm.max)^2))

#Calculation of the Root Mean Square Error for getting the accuracy of the model on the test 
RMSE.max <- function(predicted, true) mean((predicted-true)^2)^.5
RMSE.max(predict(occupancy.lm.max, test), test$Counted_client)

#CASE 2: Linear regression with Average Clients
occupancy.lm.avg = lm(Counted_client ~ Average_clients + Room + Factor_Time + Course_Level + Course_Level * Max_clients + Factor_Time * Course_Level, data=train)
#print the summary of the model
summary(occupancy.lm.avg)
#plot the residual
plot(occupancy.lm.avg)
#Calculation of the Root Mean Square Error for getting the accuracy of the model on the training 
mean(residuals(occupancy.lm.avg)^2)
sqrt(mean(residuals(occupancy.lm.avg)^2))

#Calculation of the Root Mean Square Error for getting the accuracy of the model on the test 
RMSE.avg <- function(predicted, true) mean((predicted-true)^2)^.5
RMSE(predict(occupancy.lm.avg, test), test$Counted_client)

# Glm with poisson distribution
occupancy.poisson1 = glm(Counted_client ~ Max_clients + Room + Factor_Time + Course_Level + Course_Level * Max_clients + Factor_Time * Course_Level, family = poisson, data=AnalysisTable)
summary(occupancy.poisson1)
plot(occupancy.poisson1)

#This model suffer of overdispersion, therefore we corrected the standard errors using a quasi-GLM model where the variance is given by ?? × ?? , where ?? is the mean and ?? the dispersion parameter. 

occupancy.poisson2 = glm(Counted_client ~ Max_clients + Room + Factor_Time + Course_Level + Course_Level * Max_clients + Factor_Time * Course_Level, family = quasipoisson, data=AnalysisTable)
summary(occupancy.poisson2)

#code for plotting the residuals
res <- residuals(occupancy.poisson2, type="deviance")
plot(log(predict(occupancy.poisson2)), res)
abline(h=0, lty=2)
qqnorm(res)
qqline(res)


#<--------------------k -Fold Cross-Validation --------------------------------->

#The k - fold method randomly removes k - folds for the testing set and models the remaining (training set) data. Here we use the commonly accepted (Harrell, 1998) 10 - fold application.  

################################### LINEAR MODEL#################################

#CASE1: Linear regression with Max_client
xlm.occupancy <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Counted_client ~ Max_clients + Room + Factor_Time + Course_Level + Course_Level * Max_clients + Factor_Time * Course_Level))

#Overall mean square = 412. Smaller is the mean square error, higher is the precision of our estimate. The model is pretty bad.

#CASE2: Linear regression with Average_client
xlm.occupancy2 <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Counted_client ~Average_clients + Room + Factor_Time + Course_Level + Course_Level * Average_clients + Factor_Time * Course_Level))

#Overall mean square = 402. Smaller is the mean square error, higher is the precision of our estimate. The model is pretty bad.

##############################GLM WITH POISSON DISTRIBUTION###################### 

#This model suffer of overdispersion, therefore we corrected the standard errors using a quasi-GLM model. 

occupancy.poisson <- glm(Counted_client ~ Max_clients + Room + Factor_Time + Course_Level + Course_Level * Max_clients + Factor_Time * Course_Level, family = quasipoisson, data=AnalysisTable)

#k-fold cross validation
k.occupancy <- cv.glm (data=AnalysisTable, glmfit= occupancy.poisson, K=10)
k.occupancy$delta
#raw cross validation estimate of prediction error = 1172 and the adjusted cross validation estimate = 1093, which it is pretty big.

#<----------------------------------OUTLIERS ----------------------------------->
#From the hist we could see that max_client and average_client has 2 bin that they seems to be outliers (150 and 200). I remove from the dataset all the rows where max_client is higher than 150.

NoOutlierTable <- AnalysisTable[ AnalysisTable$Max_clients < 150,] 
NoOutlierTable <- NoOutlierTable[ NoOutlierTable$Counted_client < 120,] 

dim(NoOutlierTable) #only 3 observations were dropped, so we did not lose to much data
summary(NoOutlierTable)

#Recheching the hist

#histogram for showing the count in each bin for the Maximum number of clients
histo1 <- ggplot(NoOutlierTable, aes(x = Max_clients)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#histogram for showing the count in each bin for the Average number of clients
histo2 <- ggplot(NoOutlierTable, aes(x = Average_clients)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#histogram for showing the count in each bin for the number of clients counted with the survey
histo3 <- ggplot(NoOutlierTable, aes(x = Counted_client)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 


#plot all the histograms in one window
multiplot(histo1, histo2, histo3, cols=2)
#hist seems fine

#<--------------------k -Fold Cross-Validation without outlier--------------------------------->

#The k - fold method randomly removes k - folds for the testing set and models the remaining (training set) data. Here we use the commonly accepted (Harrell, 1998) 10 - fold application.  

################################### LINEAR MODEL#################################

#CASE1: Linear regression with Max_client
xlm.occupancy.noOutlier1 <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Counted_client ~ Max_clients + Room + Factor_Time + Course_Level + Course_Level * Max_clients + Factor_Time * Course_Level))

#Overall mean square = 423. The model is still pretty bad.

#Looking at the residuals on the model run on the whole data set

occupancy.lm.test1 = lm(Counted_client ~ Max_clients + Room + Factor_Time + Course_Level + Course_Level * Max_clients + Factor_Time * Course_Level, data=NoOutlierTable)
#print the summary of the model
summary(occupancy.lm.test1)
#plot the residual
plot(occupancy.lm.test1)

#CASE2: Linear regression with Average_client
xlm.occupancy.noOutlier2 <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Counted_client ~Average_clients + Room + Factor_Time + Course_Level + Course_Level * Average_clients + Factor_Time * Course_Level))

#Overall mean square = 395. The model is still pretty bad.

##############################GLM WITH POISSON DISTRIBUTION###################### 

#This model suffer of overdispersion, therefore we corrected the standard errors using a quasi-GLM model. 

occupancy.poisson.noOutlier <- glm(Counted_client ~ Max_clients + Room + Factor_Time + Course_Level + Course_Level * Max_clients + Factor_Time * Course_Level, family = quasipoisson, data=NoOutlierTable)

#k-fold cross validation
k.occupancy.noOutlier <- cv.glm (data=NoOutlierTable, glmfit= occupancy.poisson.noOutlier, K=10)
occupancy.poisson.noOutlier$delta
#warning!!

#The Linear model seems to not be a good approach for these analyses. Looking at the histogram of the Counted client we can see that it is not normal distributed and this is causing problem.

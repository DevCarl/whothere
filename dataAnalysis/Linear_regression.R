#Upload all the libraries necessary for the analyses.
library(RMySQL) #package for communicate with MySQL database
library(ggplot2) #package for making graphs
library(GGally)
library(nlme)
library(caret) # for splitting the database
library(DAAG)#for k-fold validation on linear and logistic
library(boot)#for k-fold validation on glm
library(MuMIn)
source("http://peterhaschke.com/Code/multiplot.R") #for using 


#set up connection to the dataset
#from the server
#connection <- dbConnect(MySQL(),user="student", password="goldilocks",dbname="who_there_db", host="localhost")
#connect from xamp
connection <- dbConnect(MySQL(),user="root", password="",dbname="who_there_db", host="localhost")

#create the query
query <-"SELECT W.`Room_Room_id` as Room, W.`Date`, HOUR( W.Time ) as Time, T.`Module_Module_code` as Module, M.`Course_Level`,T.`Tutorial`, T.`Double_module`, T.`Class_went_ahead`, R.`Capacity`, G.`Percentage_room_full`, AVG(W.`Associated_client_counts`) as Wifi_Average_logs, MAX(W.`Authenticated_client_counts`) as Wifi_Max_logs FROM Room R, Wifi_log W, Ground_truth_data G, Time_table T, Module M WHERE W.Room_Room_id = R.Room_id AND G.Room_Room_id = W.Room_Room_id AND W.Date = G.Date AND HOUR( W.Time ) = HOUR( G.Time ) AND HOUR( W.Time ) = HOUR( T.Time_period ) AND T.Date = W.Date AND T.Room_Room_id = W.Room_Room_id AND M.`Module_code` = T.`Module_Module_code` GROUP BY W.Room_Room_id, HOUR( W.Time ) , W.Date"

#select the data based on the query and store them in a dataframe called Analysis table
AnalysisTable <-dbGetQuery(connection, query)

# <--------------------------- DATA QUALITY REPORT --------------------------->
#get the dimension of the datasets
dim (AnalysisTable)

#get the first six rows of the dataset (by default)
head(AnalysisTable)

#get the last six rows of the dataset
tail(AnalysisTable)

#create the new column for getting number of people counted through ground truth data
AnalysisTable$Survey_occupancy <- AnalysisTable$Capacity * AnalysisTable$Percentage_room_full

#bin time into a categorical variable for checking time of the day
AnalysisTable$Factor_Time <-cut(AnalysisTable$Time, breaks = 4, right=FALSE, labels=c('Early Morning','Late Morning','Early Afternoon','Late Afternoon' ))


#get general information on the dataset, head, tail and type of variables
str(AnalysisTable)

#specifiy as factor: Module, Course_levels, Tutorial, Double Module and Class went ahead
AnalysisTable$Room <- as.factor(AnalysisTable$Room)
AnalysisTable$Course_Level <- as.factor(AnalysisTable$Course_Level)
AnalysisTable$Tutorial <- as.factor(AnalysisTable$Tutorial)
AnalysisTable$Double_module <- as.factor(AnalysisTable$Double_module)
AnalysisTable$Class_went_ahead <- as.factor(AnalysisTable$Class_went_ahead)

#checked if the changes went ahead
str(AnalysisTable)

# get descriptive stats for all the features and checks for NAN
summary(AnalysisTable)

###################GRAPH FOR CONTINUOUS DATA############################


#histogram for showing the count in each bin for the Maximum number of clients
histo1 <- ggplot(AnalysisTable, aes(x = Wifi_Max_logs)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#histogram for showing the count in each bin for the Average number of clients
histo2 <- ggplot(AnalysisTable, aes(x = Wifi_Average_logs)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#histogram for showing the count in each bin for the number of clients counted with the survey
histo3 <- ggplot(AnalysisTable, aes(x = Survey_occupancy)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#histogram for showing the count in each bin for each hour of the day
histo4 <- ggplot(AnalysisTable, aes(x = Time)) + geom_histogram(binwidth = 2,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#plot all the histograms in one window
multiplot(histo1, histo2, histo3, histo4, cols=2)

#make the boxplot for continuous variable
#box plot for the counted client varable
box1 <- ggplot(AnalysisTable, aes(x = factor(0), y = Survey_occupancy)) + geom_boxplot() + xlab("Counted clients") + ylab("")+ scale_x_discrete(breaks = NULL) + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#box plot for the counted clients variable
box2 <- ggplot(AnalysisTable, aes(x = factor(0), y = Wifi_Average_logs)) + geom_boxplot() + xlab("Average counted clients") + ylab("")+ scale_x_discrete(breaks = NULL)  + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#box plot for the maximum number of clients variable
box3 <- ggplot(AnalysisTable, aes(x = factor(0), y =Wifi_Max_logs)) + geom_boxplot() + xlab("Maximum counted clients") + ylab("")+ scale_x_discrete(breaks = NULL) + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#box plot for the Time continuous variable
box4 <- ggplot(AnalysisTable, aes(x = factor(0), y = Time)) + geom_boxplot() + xlab("Time") + ylab("")+ scale_x_discrete(breaks = NULL) + theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 
#plot all the boxplots in one window
multiplot(box1, box2, box3, box4, cols=2)


############################GRAPHS FOR CATEGORICAL DATA##################################

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

ggpairs(AnalysisTable, columns = c('Survey_occupancy','Wifi_Max_logs', 'Wifi_Average_logs', 'Time'), lower = list(continuous = my_fn)) + theme_bw()

#Counted  clients seems to have a good correlation with Avg and Max, therefore we are will try both the model. Time does not seems to be correlated and it seems more categorical.

#--> Relationship with categorical variables

#Box plot for exploring relationship between Room and Client count
pairbox1 <- ggplot(AnalysisTable, aes(x = Room, y = Survey_occupancy)) + geom_boxplot() + theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#Box plot for exploring relationship between Room and time as a factor
pairbox2 <- ggplot(AnalysisTable, aes(x = Factor_Time, y =Survey_occupancy)) + geom_boxplot() + theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#Box plot for exploring relationship between Room and course level
pairbox3 <- ggplot(AnalysisTable, aes(x = Course_Level, y =Survey_occupancy)) + geom_boxplot()+  theme_bw()+ theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black"))

#plot all the boxplots in one window
multiplot(pairbox1, pairbox2, pairbox3, cols=2)

#####################################ANALYSIS#################################################

#<----------------------------------------LINEAR MODEL------------------------------------>
#CASE 1: MODEL SELECTION WITH RESPONSE VARIABLE AVERAGE CLIENTS

null.model <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ 1))

lm.avg <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs))

lm.avg.room <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Room))

lm.avg.time <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Factor_Time))

lm.avg.level <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Course_Level))

lm.avg.room.time <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Room + Factor_Time))

lm.avg.room.level <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Room + Course_Level))

lm.avg.time.level <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Factor_Time + Course_Level))

lm.avg.full <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Room + Factor_Time + Course_Level))

#the overall mse of the null model is:
attr(null.model, "ms")
#the overall mse of the lm.avg model is:
attr(lm.avg, "ms")
#the overall mse of the lm.avg.room model is:
attr(lm.avg.room, "ms")
#the overall mse of the lm.avg.time model is:
attr(lm.avg.time, "ms")
#the overall mse of the lm.avg.level model is:
attr(lm.avg.level, "ms")
#the overall mse of the lm.avg.room model is:
attr(lm.avg.room.time, "ms")
#the overall mse of the lm.avg.room.level model is:
attr(lm.avg.room.level, "ms")
#the overall mse of the lm.avg.time.level model is:
attr(lm.avg.time.level, "ms")
#the overall mse of the avg.full model is:
attr(lm.avg.full, "ms")

#The model with the lowest MSE was the model with only the average logs (343)

#CASE 2: MODEL SELECTION WITH RESPONSE VARIABLE MAX CLIENTS

null.model.max <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ 1))

lm.max <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs))

lm.max.room <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Room))

lm.max.time <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Factor_Time))

lm.max.level <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Course_Level))

lm.max.room.time <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Room + Factor_Time))

lm.max.room.level <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Room + Course_Level))

lm.max.time.level <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Factor_Time + Course_Level))

lm.max.full <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Room + Factor_Time + Course_Level))

#the overall mse of the null model is:
attr(null.model.max, "ms")
#the overall mse of the lm.max model is:
attr(lm.max, "ms")
#the overall mse of the lm.max.room model is:
attr(lm.max.room, "ms")
#the overall mse of the lm.max.time model is:
attr(lm.max.time, "ms")
#the overall mse of the lm.max.level model is:
attr(lm.max.level, "ms")
#the overall mse of the lm.max.room model is:
attr(lm.max.room.time, "ms")
#the overall mse of the lm.max.room.level model is:
attr(lm.max.room.level, "ms")
#the overall mse of the lm.max.time.level model is:
attr(lm.max.time.level, "ms")
#the overall mse of the lm.max.full model is:
attr(lm.max.full, "ms")

#The model with the lowest MSE was the model with only the max logs as response variable (373), which was slightly higher than the previous best model.
#Therefore we are going to run the Survey_occupancy ~ Wifi_Average_logs on the whole model
occupancy.lm.avg <- lm(Survey_occupancy ~ Wifi_Average_logs, data=AnalysisTable)
summary(occupancy.lm.avg)
#plot the residual
plot(occupancy.lm.avg)
#The diagnostic plot were very bad, so we decided to redo all the analysis with the GLM with Poisson distribution
#<---------------------------------GLM WITH POISSON DISTRIBUTION-------------------------------->
#This model suffered of overdispersion, therefore we corrected the standard errors using a quasi-GLM model. 

#Case1: Avg logs as response variable

avg.null <- glm(Survey_occupancy ~ 1, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.avg.null <- cv.glm (data=AnalysisTable, glmfit=avg.null, K=10)

avg <- glm(Survey_occupancy ~ Wifi_Average_logs, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.avg <- cv.glm (data=AnalysisTable, glmfit=avg, K=10)

avg.room <- glm(Survey_occupancy ~Wifi_Average_logs + Room, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.avg.room <- cv.glm (data=AnalysisTable, glmfit=avg.room, K=10)

avg.time <- glm(Survey_occupancy ~ Wifi_Average_logs + Factor_Time, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.avg.time <- cv.glm (data=AnalysisTable, glmfit=max.time, K=10)

avg.level <- glm(Survey_occupancy ~ Wifi_Average_logs + Course_Level, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.avg.level <- cv.glm (data=AnalysisTable, glmfit=avg.level, K=10)

avg.room.time <- glm(Survey_occupancy ~ Wifi_Average_logs + Room + Factor_Time, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.avg.room.time <- cv.glm (data=AnalysisTable, glmfit=avg.room.time, K=10)

avg.room.level <- glm(Survey_occupancy ~ Wifi_Average_logs + Room + Course_Level, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.avg.room.level <- cv.glm (data=AnalysisTable, glmfit=avg.room.level, K=10)


avg.time.level <- glm(Survey_occupancy ~ Wifi_Average_logs + Factor_Time + Course_Level, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.avg.time.level <- cv.glm (data=AnalysisTable, glmfit=max.time.level, K=10)

avg.full <- glm(Survey_occupancy ~ Wifi_Average_logs + Room + Factor_Time + Course_Level, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.avg.full <- cv.glm (data=AnalysisTable, glmfit=avg.full, K=10)

#the raw cross-validation estimate of prediction error and the adjusted one of the avg null model is:
poisson.avg.null$delta
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max model is:
poisson.avg$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.room model is:
poisson.avg.room$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.time model is:
poisson.avg.time$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.level model is:
poisson.avg.level$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.room.time model is:
poisson.avg.room.time$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.room.level model is:
poisson.avg.room.level$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.time.level model is:
poisson.avg.time.level$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.full model is:
poisson.avg.full$delta 

#The best model was poisson.avg.time.level with an adjusted cross-validation estimate of prediction error of: 604

#Case2: Max logs as response variable

max.null <- glm(Survey_occupancy ~ 1, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.max.null <- cv.glm (data=AnalysisTable, glmfit=max.null, K=10)

max <- glm(Survey_occupancy ~ Wifi_Max_logs, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.max <- cv.glm (data=AnalysisTable, glmfit=max, K=10)

max.room <- glm(Survey_occupancy ~ Wifi_Max_logs + Room, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.max.room <- cv.glm (data=AnalysisTable, glmfit=max.room, K=10)

max.time <- glm(Survey_occupancy ~ Wifi_Max_logs + Factor_Time, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.max.time <- cv.glm (data=AnalysisTable, glmfit=max.time, K=10)

max.level <- glm(Survey_occupancy ~ Wifi_Max_logs + Course_Level, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.max.level <- cv.glm (data=AnalysisTable, glmfit=max.level, K=10)

max.room.time <- glm(Survey_occupancy ~ Wifi_Max_logs + Room + Factor_Time, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.max.room.time <- cv.glm (data=AnalysisTable, glmfit=max.room.time, K=10)

max.room.level <- glm(Survey_occupancy ~ Wifi_Max_logs + Room + Course_Level, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.max.room.level <- cv.glm (data=AnalysisTable, glmfit=max.room.level, K=10)


max.time.level <- glm(Survey_occupancy ~ Wifi_Max_logs + Factor_Time + Course_Level, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.max.time.level <- cv.glm (data=AnalysisTable, glmfit=max.time.level, K=10)

max.full <- glm(Survey_occupancy ~ Wifi_Max_logs + Room + Factor_Time + Course_Level, family = quasipoisson, data=AnalysisTable)
#k-fold cross validation
poisson.max.full <- cv.glm (data=AnalysisTable, glmfit=max.full, K=10)

#the raw cross-validation estimate of prediction error and the adjusted one of the null model is:
poisson.max.null$delta
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max model is:
poisson.max$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.room model is:
poisson.max.room$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.time model is:
poisson.max.time$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.level model is:
poisson.max.level$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.room.time model is:
poisson.max.room.time$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.room.level model is:
poisson.max.room.level$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.time.level model is:
poisson.max.time.level$delta 
#the raw cross-validation estimate of prediction error and the adjusted one of the poisson.max.full model is:
poisson.max.full$delta 

# The best model was the poisson.max.full with an adjusted cross-validation estimate of prediction error of:  560
#Therefore we are going to run this model on the whole dataset.

summary(max.full)


#code for plotting the residuals
res <- residuals(max.full, type="deviance")
plot(log(predict(max.full)), res)
abline(h=0, lty=2)
qqnorm(res)
qqline(res)

#However also the diagnostic graph of this model did not look promising
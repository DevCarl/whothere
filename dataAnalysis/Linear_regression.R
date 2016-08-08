#Upload all the libraries necessary for the analyses.
library(RMySQL) #package for communicate with MySQL database
library(ggplot2) #package for making graphs
library(GGally)
library(nlme)
library(caret) # for splitting the database
library(DAAG)#for k-fold validation on linear and logistic
library(boot)#for k-fold validation on glm
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
write.csv(AnalysisTable, file = "AnalysisTable.csv",row.names=FALSE)

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
#NULL MODEL
null.model <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ 1))

#CASE 1: MODEL SELECTION WITH RESPONSE VARIABLE AVERAGE CLIENTS
lm.avg <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs))

lm.avg.room <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Room))

lm.avg.time <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Factor_Time))

lm.avg.level <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Course_Level))

lm.avg.room.time <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Room + Factor_Time))

lm.avg.room.level <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Room + Course_Level))

lm.avg.time.level <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Factor_Time + Course_Level))

lm.avg.full <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Room + Factor_Time + Course_Level))

#PRINT THE MSE FOR ALL THE MODELS
print(paste('The MSE of the model Survey_occupancy ~ 1:', attr(null.model, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Average_logs was:', attr(lm.avg, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Average_logs + Room was:', attr(lm.avg.room, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Average_logs + Time was:',attr(lm.avg.time, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Average_logs + Course_Level was:', attr(lm.avg.level, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Average_logs + Room + Time was:', attr(lm.avg.room.time, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Average_logs+Room+level was:',attr(lm.avg.room.level, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Average_logs + Time + course_Levels was:',attr(lm.avg.time.level, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Average_logs + Room + Time + Course_Level was:', attr(lm.avg.full, "ms")))

#The model with the lowest MSE was the model with only the average logs (343).

#CASE 2: MODEL SELECTION WITH RESPONSE VARIABLE MAX CLIENTS
lm.max <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs))

lm.max.room <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Room))

lm.max.time <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Factor_Time))

lm.max.level <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Course_Level))

lm.max.room.time <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Room + Factor_Time))

lm.max.room.level <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Room + Course_Level))

lm.max.time.level <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Factor_Time + Course_Level))

lm.max.full <- CVlm (data=AnalysisTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Room + Factor_Time + Course_Level))

#SUMMARY OF THE MSE:
print(paste('The MSE of the model Survey_occupancy ~ 1 is:', attr(null.model, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Max_logs is:', attr(lm.max, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Max_logs + Room is:',attr(lm.max.room, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Max_logs + Time is:', attr(lm.max.time, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Max_logs + Course_Level is:', attr(lm.max.level, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Max_logs + Room + Time is:',attr(lm.max.room.time, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Max_logs + Room + Course_Levels is:',attr(lm.max.room.level, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Max_logs + Room + Time is:', attr(lm.max.time.level, "ms")))

print(paste('The MSE of the model Survey_occupancy ~ Wifi_Max_logs + Room + Time + Course_level is:',attr(lm.max.full, "ms")))

#The model with the lowest MSE was the model with only the max logs as response variable (373), which was slightly higher than the previous best model.

#Therefore we are going to run the Survey_occupancy ~ Wifi_Average_logs on the whole dataset.
occupancy.lm.avg <- lm(Survey_occupancy ~ Wifi_Average_logs, data=AnalysisTable)

#looking at the model
summary(occupancy.lm.avg)
#plot the residual
plot(occupancy.lm.avg)

#The diagnostic plot showed that there was an outlier. Therefore, we are going to remove it and re-run the analysis.

#<----------------------------------OUTLIERS ----------------------------------->
#From the hist we could see that max_client and average_client has 2 bin that they seems to be outliers (150 and 200). I remove from the dataset all the rows where max_client is higher than 150.

NoOutlierTable <- AnalysisTable[ AnalysisTable$Wifi_Max_logs < 150,] 
NoOutlierTable <- NoOutlierTable[ NoOutlierTable$Survey_occupancy < 120,] 

dim(NoOutlierTable) #only 3 observations were dropped, so we did not lose to much data
summary(NoOutlierTable)

#Recheching the hist

#histogram for showing the count in each bin for the Maximum number of clients
histo1 <- ggplot(NoOutlierTable, aes(x = Wifi_Max_logs)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#histogram for showing the count in each bin for the Average number of clients
histo2 <- ggplot(NoOutlierTable, aes(x = Wifi_Average_logs)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 

#histogram for showing the count in each bin for the number of clients counted with the survey
histo3 <- ggplot(NoOutlierTable, aes(x = Survey_occupancy)) + geom_histogram(binwidth = 10,  col="red", aes(fill=..count..)) + scale_fill_gradient("Count", low = "yellow", high = "red") +theme_bw()+theme(panel.border = element_blank(), panel.grid.major = element_blank(), panel.grid.minor = element_blank(), axis.line = element_line(colour = "black")) 


#plot all the histograms in one window
multiplot(histo1, histo2, histo3, cols=2)
#hist seems fine for avg and max, but not for Wifi avg clients

#<--------------------k -Fold Cross-Validation without outlier--------------------------------->

#<----------------------------------------LINEAR MODEL------------------------------------>
#CASE 1: MODEL SELECTION WITH RESPONSE VARIABLE AVERAGE CLIENTS

out.null.model <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ 1))

out.lm.avg <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs))

out.lm.avg.room <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Room))

out.lm.avg.time <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Factor_Time))

out.lm.avg.level <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Course_Level))

out.lm.avg.room.time <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Room + Factor_Time))

out.lm.avg.room.level <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Room + Course_Level))

out.lm.avg.time.level <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Factor_Time + Course_Level))

out.lm.avg.full <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Average_logs + Room + Factor_Time + Course_Level))

#MSE FOR ALL THE MODELS
print(paste ( 'The MSE of the Survey_occupancy ~ 1  model (null model) is:', attr(out.null.model, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Average_logs model is:', attr(out.lm.avg, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Average_logs + Room model is:', attr(out.lm.avg.room, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Average_logs + Time model is:', attr(out.lm.avg.time, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Average_logs + Course Level model is:', attr(out.lm.avg.level, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Average_logs + Room + Time model is:', attr(out.lm.avg.room.time, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Average_logs + Room + Course Level model is:', attr(out.lm.avg.room.level, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Average_logs + Room + Course Level model is:', attr(out.lm.avg.time.level, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Average_logs + Room + Course Level model is:', attr(out.lm.avg.full, "ms")))



#The model with the lowest MSE was the model with only the average logs (315). Slighty improved from the first time.

#CASE 2: MODEL SELECTION WITH RESPONSE VARIABLE MAX CLIENTS

out.lm.max <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs))

out.lm.max.room <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Room))

out.lm.max.time <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Factor_Time))

out.lm.max.level <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Course_Level))

out.lm.max.room.time <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Room + Factor_Time))

out.lm.max.room.level <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Room + Course_Level))

out.lm.max.time.level <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Factor_Time + Course_Level))

out.lm.max.full <- CVlm (data=NoOutlierTable, m= 10, form.lm = formula (Survey_occupancy ~ Wifi_Max_logs + Room + Factor_Time + Course_Level))

#MSE FOR ALL THE MODELS
print(paste ( 'The MSE of the Survey_occupancy ~ 1  model (null model) is:', attr(out.null.model, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Max_logs model is:', attr(out.lm.max, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Max_logs + Room model is:', attr(out.lm.max.room, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Max_logs + Time model is:', attr(out.lm.max.time, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Max_logs + Course Level model is:', attr(out.lm.max.level, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Max_logs + Room + Time model is:', attr(out.lm.max.room.time, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Max_logs + Room + Course Level model is:', attr(out.lm.max.room.level, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Max_logs + Room + Course Level model is:', attr(out.lm.max.time.level, "ms")))
print(paste ( 'The MSE of the Survey_occupancy ~ Wifi_Max_logs + Room + Course Level model is:', attr(out.lm.max.full, "ms")))

#The model with the lowest MSE was the model with only the max logs as response variable (337), which was slightly higher than the previous best model.
#Therefore we are going to run the Survey_occupancy ~ Wifi_Average_logs on the whole dataset
out.occupancy.lm.avg <- lm(Survey_occupancy ~ Wifi_Average_logs, data=NoOutlierTable)
summary(out.occupancy.lm.avg)
#plot the residual
plot(out.occupancy.lm.avg)
#From the plot looking at the residual vs fitted values, we still could see that the Survey occupancy was assuming more or less the same values and this explain the line pattern of the graphs. The data were quite normal distributed, but the variance did not seem homogeneous.

log.occupancy.lm.avg <- lm(log(Survey_occupancy+1) ~ Wifi_Average_logs, data=NoOutlierTable)
summary(log.occupancy.lm.avg)
#plot the residual
plot(log.occupancy.lm.avg)
#<---------------------------------GLM WITH POISSON DISTRIBUTION-------------------------------->
#This model suffered of overdispersion, therefore we corrected the standard errors using a quasi-GLM model. 

#Case1: Avg logs as response variable

set.seed(1)
out.avg.null <- glm(Survey_occupancy ~ 1, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.null <- cv.glm (data=NoOutlierTable, glmfit=out.avg.null, K=10)

out.avg <- glm(Survey_occupancy ~ Wifi_Average_logs, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.avg <- cv.glm (data=NoOutlierTable, glmfit=out.avg, K=10)

out.avg.room <- glm(Survey_occupancy ~Wifi_Average_logs + Room, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.avg.room <- cv.glm (data=NoOutlierTable, glmfit=out.avg.room, K=10)

out.avg.time <- glm(Survey_occupancy ~ Wifi_Average_logs + Factor_Time, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.avg.time <- cv.glm (data=NoOutlierTable, glmfit=out.avg.time, K=10)

out.avg.level <- glm(Survey_occupancy ~ Wifi_Average_logs + Course_Level, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.avg.level <- cv.glm (data=NoOutlierTable, glmfit=out.avg.level, K=10)

out.avg.room.time <- glm(Survey_occupancy ~ Wifi_Average_logs + Room + Factor_Time, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.avg.room.time <- cv.glm (data=NoOutlierTable, glmfit=out.avg.room.time, K=10)

out.avg.room.level <- glm(Survey_occupancy ~ Wifi_Average_logs + Room + Course_Level, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.avg.room.level <- cv.glm (data=NoOutlierTable, glmfit=out.avg.room.level, K=10)

out.avg.time.level <- glm(Survey_occupancy ~ Wifi_Average_logs + Factor_Time + Course_Level, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.avg.time.level <- cv.glm (data=NoOutlierTable, glmfit=out.avg.time.level, K=10)

out.avg.full <- glm(Survey_occupancy ~ Wifi_Average_logs + Room + Factor_Time + Course_Level, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.avg.full <- cv.glm (data=NoOutlierTable, glmfit=out.avg.full, K=10)

print(paste('the adjusted cross-validation estimate of prediction error of the glm Survey_occupancy ~ 1 is:', out.poisson.null$delta[2]))
print(paste('the adjusted cross-validation estimate of prediction error of the glm Survey_occupancy ~ Wifi_Average_logs is:', out.poisson.avg$delta[2])) 
print(paste('the adjusted cross-validation estimate of prediction error of the glm Survey_occupancy ~ Wifi_Average_logs + Room is:',out.poisson.avg.room$delta[2]))
print(paste('the adjusted cross-validation estimate of prediction error of the glm Survey_occupancy ~ Wifi_Average_logs + Time is:',out.poisson.avg.time$delta[2]))
print(paste('the adjusted cross-validation estimate of prediction error of the glm Survey_occupancy ~ Wifi_Average_logs + Course Level is:',out.poisson.avg.level$delta[2])) 
print(paste('the adjusted cross-validation estimate of prediction error of the glm Survey_occupancy ~ Wifi_Average_logs + Room + Time is:',out.poisson.avg.room.time$delta[2]))
print(paste('the adjusted cross-validation estimate of prediction error of the glm Survey_occupancy ~ Wifi_Average_logs + Room +Course Level is:',out.poisson.avg.room.level$delta[2]))
print(paste('the adjusted cross-validation estimate of prediction error of the glm Survey_occupancy ~ Wifi_Average_logs + Time + Course Level is:', out.poisson.avg.time.level$delta[2]))
print(paste('the adjusted cross-validation estimate of prediction error of the glm Survey_occupancy ~ Wifi_Average_logs + Room + Time + Course Level is:', out.poisson.avg.full$delta[2])) 

#The best model was Survey_occupancy ~ Wifi_Average_logs with an adjusted cross-validation estimate of prediction error of 390.

#Case2: Max logs as response variable
set.seed(1)
out.max <- glm(Survey_occupancy ~ Wifi_Max_logs, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.max <- cv.glm (data=NoOutlierTable, glmfit=out.max, K=10)

out.max.room <- glm(Survey_occupancy ~ Wifi_Max_logs + Room, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.max.room <- cv.glm (data=NoOutlierTable, glmfit=out.max.room, K=10)

out.max.time <- glm(Survey_occupancy ~ Wifi_Max_logs + Factor_Time, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.max.time <- cv.glm (data=NoOutlierTable, glmfit=out.max.time, K=10)

out.max.level <- glm(Survey_occupancy ~ Wifi_Max_logs + Course_Level, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.max.level <- cv.glm (data=NoOutlierTable, glmfit=out.max.level, K=10)

out.max.room.time <- glm(Survey_occupancy ~ Wifi_Max_logs + Room + Factor_Time, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.max.room.time <- cv.glm (data=NoOutlierTable, glmfit=out.max.room.time, K=10)

out.max.room.level <- glm(Survey_occupancy ~ Wifi_Max_logs + Room + Course_Level, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.max.room.level <- cv.glm (data=NoOutlierTable, glmfit=out.max.room.level, K=10)


out.max.time.level <- glm(Survey_occupancy ~ Wifi_Max_logs + Factor_Time + Course_Level, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.max.time.level <- cv.glm (data=NoOutlierTable, glmfit=out.max.time.level, K=10)

out.max.full <- glm(Survey_occupancy ~ Wifi_Max_logs + Room + Factor_Time + Course_Level, family = quasipoisson, data=NoOutlierTable)
#k-fold cross validation
out.poisson.max.full <- cv.glm(data=NoOutlierTable, glmfit=out.max.full, K=10)

print(paste('the adjusted cross-validation estimate of prediction error of the glm Survey_occupancy ~ 1 is:', out.poisson.null$delta[2]}))
print(paste('the adjusted cross-validation estimate of prediction error of the glm  Survey_occupancy ~ Wifi_Max_logs is:', out.poisson.max$delta[2])) 
print(paste('the adjusted cross-validation estimate of prediction error of the glm  Survey_occupancy ~ Wifi_Max_logs + Room is:',out.poisson.max.room$delta[2])) 
print(paste('the adjusted cross-validation estimate of prediction error of the glm  Survey_occupancy ~ Wifi_Max_logs + Time is:',out.poisson.max.time$delta[2]))
print(paste('the adjusted cross-validation estimate of prediction error of the glm  Survey_occupancy ~ Wifi_Max_logs + Course Level is:',out.poisson.max.level$delta[2]))
print(paste('the adjusted cross-validation estimate of prediction error of the glm  Survey_occupancy ~ Wifi_Max_logs + Room + Time is:',out.poisson.max.room.time$delta[2]))
print(paste('the adjusted cross-validation estimate of prediction error of the glm  Survey_occupancy ~ Wifi_Max_logs + Room +Course Level is:',out.poisson.max.room.level$delta[2]))
print(paste('the adjusted cross-validation estimate of prediction error of the glm  Survey_occupancy ~ Wifi_Max_logs + Time + Course Level is:', out.poisson.max.time.level$delta[2]))
print(paste('the adjusted cross-validation estimate of prediction error of the glm  Survey_occupancy ~ Wifi_Max_logs + Room + Time + Course Level is:', out.poisson.max.full$delta[2])) 


#The best model was the out.poisson.max with an adjusted cross-validation estimate of prediction error of: 394, which was slightly worst than the model with the average logs as predictor. 
#Therefore we are going to run Survey_occupancy ~ Wifi_Average_logs this model on the whole dataset. To validate the model we plotted the following residuals, as suggested by Zuur et al. (2009): Ordinal residuals, Pearson residual, scaled Pearson residuals (to take into account the overdispersion) and the deviance residuals for the optimal quasi-Poisson model applied on the dataset without outliers. We plotted also the deviance residuals aganist the explanatory variable Wifi_Average_log to see whether there was any patterns.

Pearson_Residuals <- resid(out.avg, type = "pearson")
Deviance_Residuals <- resid(out.avg, type = "deviance")
mu <- predict(out.avg, type = "response")
Response_Residuals <- NoOutlierTable$Survey_occupancy - Predicted_probabilities
Scaled_Pearson_Residuals <- E / sqrt(15.2 * Response_Residuals) #corrected by the overdispersion of the model
op <- par(mfrow = c(2, 2))
plot(x = mu, y = Scaled_Pearson_Residuals, main = "Response residuals")
plot(x = mu, y = Pearson_Residuals, main = "Pearson residuals")
plot(x = mu, y = Scaled_Pearson_Residuals,
     main = "Pearson residuals scaled")
plot(x = mu, y = Deviance_Residuals, main = "Deviance residuals")

par(op)

#From all the residuals plot we could see a pattern, the residuals were decresing as the average or mu of the fited values were decreasing, suggesting that the quasi-poisson glm was not appropriate. For double checking it, we checked if the variance of the residuals was proportional to the mean, as suggested by this tutorial (https://www.ssc.wisc.edu/sscc/pubs/RFR/RFR_Regression.html).
#For doing so we plotted the residuals aganist the predicted mean and in this graph we plotted 3 lines:a black line representing the Poisson assumed variance;a blue plotting the quasi-Poisson assumed variance;orange curve for the smoothed mean of the square of the residual.In theory the orange line should be straight and it will be collinear with the blue line. Higher is the deviation of the orange line from the blue one, higher is the chance that the variance of the quasi-Poisson model is not proportional to the mean as aspected. 

p1 <- glm(Survey_occupancy ~ Wifi_Average_logs, family="poisson", data=NoOutlierTable)
drop1(p1, test="F")
```
```{r, echo=TRUE, warning=FALSE}
#This plot reveal overdispersion, therefore we are trying to run the negative binomial distribution.
p1Diag <- data.frame(NoOutlierTable,
                     link=predict(p1, type="link"),
                     fit=predict(p1, type="response"),
                     pearson=residuals(p1,type="pearson"),
                     resid=residuals(p1,type="response"),
                     residSqr=residuals(p1,type="response")^2
)


ggplot(data=p1Diag, aes(x=fit, y=residSqr)) +
  geom_point() +
  geom_abline(intercept = 0, slope = 1) +
  geom_abline(intercept = 0, slope = summary(out.avg)$dispersion,
              color="darkcyan") +
  stat_smooth(method="loess", se = FALSE, color="orangered") +
  theme_bw() 

#As we can see from the graph, the orange smoothed mean of the square of the residual is diverging from the Poisson assumed variance. For this reason, the quasi-poisson model was not appropriate for our data. 
#Therefore,  we decided to run the model using a negative bionomial distribution that it is designed to deal with overdispersion.


library(MASS)  
nb.avg <- glm.nb(Survey_occupancy ~ Wifi_Average_logs, data=NoOutlierTable)
summary(nb.avg)
```

#The negative bionomial model, however, has a very high dispersion parameter and it was suited for our data. Therefore the linear model was selected as our best model.
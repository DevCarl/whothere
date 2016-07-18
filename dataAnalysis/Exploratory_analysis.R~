# <-------------------------------------- DATABASE --------------------------->
#In this section the connection with the database is made, database tables 
# are checked and the quiery to selected the data needed for the analysis is selected

# open RMySQL
library(RMySQL)

#set up connection
connection <- dbConnect(MySQL(),user="root", password="goldilocks",dbname="Who_there_db", host="localhost")

#get the list of tables present in the DB: dbListTables(nameOfConnection)
dbListTables(connection)

#show the field names for a given table: dbListFields(connection, table name).
dbListFields(connection, "Room")

#create the query
query <-"select * from Wifi_log;"

#select the data based on the query and store them in a dataframe called Analysis table
AnalysisTable <-dbGetQuery(connection, query)

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

#GRAPH FOR CONTINUOUS DATA

#histogram for showing the count in each bin
#h1 <- ggplot(AnalysisTable, aes(x = variable)) + geom_histogram(binwidth = 2)

#histogram for showing the the proportion of data in the corresponding interval.
histo1 <- ggplot(AnalysisTable, aes(x = variable)) + geom_histogram(binwidth = 2, aes(y = ..density..)
#h2 <-
#h3<-
  
#plot all the histograms in one window

#multiplot(histo1, histo2, histo3, histo4, cols=2)

#make the boxplot for continuous variable
  
#box <- ggplot(AnalysisTable, aes(x = factor(0), y = variable)) + geom_boxplot() + xlab("") +
#scale_x_discrete(breaks = NULL) + coord_flip()

#plot all the histograms in one window

#multiplot(box1, box2, box3, box4, cols=2)

#GRAPH FOR CATEGORICAL DATA
#bar <- ggplot(AnalysisTable, aes(x = Level)) + geom_bar()


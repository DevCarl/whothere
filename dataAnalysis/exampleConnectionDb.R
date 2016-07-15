# install RMySQL package
install.packages("RMySQL")

#check the directory 
getwd()
#set the directory for save your work
setwd("/Users/Cometa/Desktop/ResearchPracticum/analyses/dbConnection")
#recheck
getwd()

# open RMySQL
library(RMySQL)
#access the data present in R

#set up connection
con <- dbConnect(MySQL(),user="root", password="", dbname="classicmodels", host="localhost")

#get the list of tables present in the DB: dbListTables(nameOfConnection)
dbListTables(con)

#show the field names for a given table: dbListFields(connection, table name).
dbListFields(con, "employees")

#example of query
customerTable <-dbGetQuery(con, "SELECT * FROM customers ORDER BY customers.country ASC")

# summarySE provides the standard deviation, standard error of the mean, and a (default 95%) confidence interval
avg <- dbGetQuery(con,"select country, avg(creditLimit) as credit from customers group by country ORDER BY customers.country ASC")

library(ggplot2)
ggplot(avg, aes(country, credit)) + geom_bar(stat="identity")

customerTable$country <- factor(customerTable$country)

lm2 =lm(creditLimit~ customerTable$country , data= customerTable )
summary(lm2)
plot(lm2)


#This document was created for learning how to make a connection between R and a database stored in XAMP. In this case the database is classicmodels (database used for an assignment in Web Development).

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

#code for making a barplot
library(ggplot2)
ggplot(avg, aes(country, credit)) + geom_bar(stat="identity")

#set up country as a factor
customerTable$country <- factor(customerTable$country)

#code for making a linear model
lm2 =lm(creditLimit~ customerTable$country , data= customerTable )
summary(lm2)
plot(lm2)


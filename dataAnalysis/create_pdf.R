library(rmarkdown)
Sys.setenv(RSTUDIO_PANDOC="C:/Program Files/RStudio/bin/pandoc")
args <- commandArgs(TRUE)
if (length(args) < 2) stop("Bad args, usage refdir cmpdir")

room <- args[1]
date_input <- args[2]
#for testing
#print(paste("room is", room))
#print(paste("date is", date))

#set the directory for the server
#render('daily_PDF_builder.Rmd', output_file =  paste('report.', Sys.Date(),'.pdf', sep=''))
input_location <- paste()
render('daily_PDF_builder.Rmd', params = list(room, date_input),output_file =  paste('report.', Sys.Date(),'.pdf', sep=''))

cat(arg[])
library(rmarkdown)
library(random)
args <- commandArgs(TRUE)
if (length(args) < 2) stop("Bad args, usage refdir cmpdir")

room <- args[1]
date_input <- args[2]
directory <- args[3]
#for testing
#print(paste("room is", room))
#print(paste("date is", date))

#set the directory for the input file
input_location <- paste(directory,'daily_PDF_builder.Rmd', sep='')
#set the directory for the output file
output_location <- paste(directory,'output_pdf/', sep='')
#generate random dataframe
r_s <- randomStrings(n=1, len=5)
#generate a random name for the output file
output_name <- paste(r_s[1,],Sys.Date(),'.pdf', sep='')
#generate the PDF with the name specified in the directory specified
render(input_location, params = list(room, date_input),output_file =output_name, output_dir = output_location)

#remove R printing decoration
cat(arg[], output_directory, output_name)
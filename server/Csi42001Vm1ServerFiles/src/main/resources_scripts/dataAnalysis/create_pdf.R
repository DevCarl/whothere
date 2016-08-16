library(rmarkdown)
library(random)
#set the directory for the server

print("Set Up")
args<-commandArgs(TRUE)
input_location <- paste(args[3], "daily_PDF_builder.Rmd", sep="")
output_location <- paste(args[3], "output_pdf", sep="")
output_name <- paste(randomStrings(n=1, len=20), ".pdf", sep="")
render(input_location, params= list(Date= args[1], Room_no= args[2]), output_dir = output_location, output_file = output_name)
cat(paste(output_location, "/", output_name, sep=""))

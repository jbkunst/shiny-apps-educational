rm(list=ls())
library(plyr)
library(lubridate)

folder_proc <- "../data_proc"
folder_data_app <- "../data_app"

files <- dir(folder_proc, full.names = TRUE)

data <- ldply(files, function(x){
  read.table(x, header = TRUE, sep = ",", stringsAsFactors = FALSE)
}, .progress="text")
gc()

str(data)

dir.create(folder_data_app)

save(data, file = file.path(folder_data_app, "data_app.RData")) 

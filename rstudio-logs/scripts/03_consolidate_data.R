rm(list=ls())
library(plyr)
library(lubridate)
library(RSQLite)
source("00_parameters.R")

files <- dir(folder_proc, full.names = TRUE)

data <- ldply(files, function(x){
  read.table(x, header = TRUE, sep = ",", stringsAsFactors = FALSE)
}, .progress="text")


try(file.remove(file.path(folder_data_app, "data_app.RData")))
try(file.remove(file.path(folder_data_app, file_sqlite_name)))

save(data, file = file.path(folder_data_app, "data_app.RData")) 

db <- dbConnect(SQLite(), dbname = file.path(folder_data_app, file_sqlite_name))
dbWriteTable(conn = db, name = "rstudio_logs", value = data)


f1 <- "2012-11-07"
f2 <- "2012-11-10"
system.time(res <- dbGetQuery(db, sprintf("select * from rstudio_logs where date >= '%s' and date <= '%s'", f1, f2)))
system.time(res <- subset(data, date >= f1 & date <= f2))

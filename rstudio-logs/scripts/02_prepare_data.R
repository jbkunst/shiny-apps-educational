rm(list=ls())
library(plyr)
library(RSQLite)
options(stringsAsFactors = FALSE)
source("00_parameters.R")


suppressWarnings(dir.create(pars$folder_data_app))

files_compress <- dir(path = pars$folder_data_raw, full.names = TRUE)
files_compress <- files_compress[file.info(files_compress)$size != 0]

data <- ldply(files_compress, function(x){  
  subset(read.table(gzfile(x), nrows =  -1, sep = ",", quote = "\"", header = TRUE), select = pars$logs_col_names)
}, .progress="text")

try(file.remove(file.path(pars$folder_data_app, pars$file_sqlite_name)))

db <- dbConnect(SQLite(), dbname = file.path(pars$folder_data_app, pars$file_sqlite_name))
dbWriteTable(conn = db, name = "rstudio_logs", value = data)



f1 <- "2012-11-07"
f2 <- "2013-11-10"
head(data)
str(data)
dim(data)

system.time(res1 <- dbGetQuery(db, sprintf("select * from rstudio_logs where date >= '%s' and date <= '%s'", f1, f2)))
system.time(res2 <- subset(data, date >= f1 & date <= f2))

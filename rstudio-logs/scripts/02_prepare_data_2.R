rm(list=ls())
library(plyr)
library(stringr)
library(RSQLite)
options(stringsAsFactors = FALSE)
source("00_parameters.R")

# d$date_revert <- format(as.POSIXct(d$timestamp, tz = "GMT", origin = "1970-01-01"), "%Y-%m-%d")
# d$time_revert <- format(as.POSIXct(d$timestamp, tz = "GMT", origin = "1970-01-01"), "%H:%M:%S") 
suppressWarnings(dir.create(pars$folder_data_app))
start <- as.numeric(strptime(paste(file_date, "00:00:00"), "%Y-%m-%d %H:%M:%S"))
end <- as.numeric(strptime(paste(file_date, "23:59:59"), "%Y-%m-%d %H:%M:%S"))

files_compress <- dir(path = pars$folder_data_raw, full.names = TRUE)
files_compress <- files_compress[file.info(files_compress)$size != 0]
files_compress <- sample(files_compress, size = 50)
files_compress <- sort(files_compress)
try(file.remove(file.path(pars$folder_data_app, pars$file_sqlite_name)))
db <- dbConnect(SQLite(), dbname = file.path(pars$folder_data_app, pars$file_sqlite_name))


files_counts <- ldply(files_compress, function(x){  # x <- sample(files_compress, size = 1)
  
  # Check if we load the data in a previous process
  file_date <- str_extract(x, "\\d{4}-\\d{2}-\\d{2}")
  
  if(nrow(dbGetQuery(db, "SELECT name FROM sqlite_master WHERE type='table' AND name='rstudio_logs'"))==0){
    db_nrow <- 0
  } else {
    db_nrow <- dbGetQuery(db, sprintf("select count(*) from rstudio_logs where date = \"%s\"", file_date))[1,1]
  }
  
  if(db_nrow == 0){
    
    # Load data and creating timestamp
    d <- subset(read.table(gzfile(x), nrows =  -1, sep = ",", quote = "\"", header = TRUE), select = pars$logs_col_names)
    # d$timestamp <- as.numeric(strptime(paste(d$date, d$time), "%Y-%m-%d %H:%M:%S"))
    # d$date_revert <- format(as.POSIXct(d$timestamp, tz = "GMT", origin = "1970-01-01"), "%Y-%m-%d")
    # d$time_revert <- format(as.POSIXct(d$timestamp, tz = "GMT", origin = "1970-01-01"), "%H:%M:%S")
    d <- subset(d, select = c("date", "time", "package", "country"))
    
    dbWriteTable(db, name = "rstudio_logs", value = d, append = TRUE)
    message(sprintf("File %s, rows %s", x, prettyNum(nrow(d), big.mark =  ".")))
    message(paste(unique(d$date), collapse =  ", "))
    data.frame(file = x, date = file_date, file_n = nrow(d))
    
    
  }
  
}, .progress="text")


test <- dbGetQuery(db, "select date, count(*) as n from rstudio_logs group by date")
test_f <- join(files_counts, test, type = "full")
test_f <- test_f[order(test_f$date),]
View(test_f)

sum(files_counts$file_n, na.rm = TRUE)
sum(test$n, na.rm = TRUE)

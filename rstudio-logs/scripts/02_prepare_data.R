rm(list=ls())
library(plyr)
library(stringr)
library(RSQLite)
options(stringsAsFactors = FALSE)
source("00_parameters.R")


suppressWarnings(dir.create(pars$folder_data_app))


files_compress <- dir(path = pars$folder_data_raw, full.names = TRUE)
files_compress <- files_compress[file.info(files_compress)$size != 0]
files_compress <- sample(files_compress, size = 5)

# try(file.remove(file.path(pars$folder_data_app, pars$file_sqlite_name)))
db <- dbConnect(SQLite(), dbname = file.path(pars$folder_data_app, pars$file_sqlite_name))


l_ply(files_compress, function(x){  # x <- sample(files_compress, size = 1)
  
  # Check if we load the data in a previous process
  file_date <- str_extract(x, "\\d{4}-\\d{2}-\\d{2}")
  start <- as.numeric(strptime(paste(file_date, "00:00:00"), "%Y-%m-%d %H:%M:%S"))
  end <- as.numeric(strptime(paste(file_date, "23:59:59"), "%Y-%m-%d %H:%M:%S"))
  
  if(nrow(dbGetQuery(db, "SELECT name FROM sqlite_master WHERE type='table' AND name='rstudio_logs'"))==0){
    db_nrow <- 0
  } else {
    db_nrow <- dbGetQuery(db, sprintf("select count(*) from rstudio_logs where timestamp >= %s and timestamp <= %s", start, end))  
  }
  

  if(db_nrow == 0){
    
    # Load data and creating timestamp
    d <- subset(read.table(gzfile(x), nrows =  -1, sep = ",", quote = "\"", header = TRUE), select = pars$logs_col_names)
    d$timestamp <- as.numeric(strptime(paste(d$date, d$time), "%Y-%m-%d %H:%M:%S")) # d$date_time_rever <- as.POSIXct(d$timestamp, tz = "", origin = "1970-01-01")
    d <- subset(d, select = c("timestamp", "package", "country"))
    
    dbWriteTable(db, name = "rstudio_logs", value = d, append = TRUE)
    
    message(sprintf("File %s, rows %s", x, prettyNum(nrow(d), big.mark =  ".")))
    
  }
    
}, .progress="text")


test <- dbGetQuery(db, "select *, date(timestamp, 'unixepoch') as date, strftime('%S', date(timestamp, 'unixepoch')) as month from rstudio_logs ORDER BY RANDOM() limit 10 ")
test$date_time_rever <- as.POSIXct(test$timestamp, tz = "", origin = "1970-01-01")
test

sqlite_count <- dbGetQuery(db, "select date(timestamp, 'unixepoch') as date, count(*) as sqlite_n from rstudio_logs group by date(timestamp, 'unixepoch')")
files_count <- ldply(files_compress, function(x){
  data.frame(date = file_date <- str_extract(x, "\\d{4}-\\d{2}-\\d{2}"),
             files_n = nrow(read.table(gzfile(x), nrows =  -1, sep = ",", quote = "\"", header = TRUE)))
}, .progress="text")

test <- join(sqlite_count, files_count, match = "all")
head(test)
test$diff <- test[,2] - test[,3]

sum(test[,2]) - sum(test[,3], na.rm = TRUE)


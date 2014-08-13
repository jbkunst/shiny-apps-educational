rm(list=ls())
library(plyr)
library(stringr)
library(RSQLite)
options(stringsAsFactors = FALSE)
source("00_parameters.R")


suppressWarnings(dir.create(pars$folder_data_app))


files_compress <- dir(path = pars$folder_data_raw, full.names = TRUE)
files_compress <- files_compress[file.info(files_compress)$size != 0]
files_compress <- files_compress[!grepl("2012-\\d{2}-\\d{2}.csv.gz$", files_compress)]

# try(file.remove(file.path(pars$folder_data_app, pars$file_sqlite_name)))
db <- dbConnect(SQLite(), dbname = file.path(pars$folder_data_app, pars$file_sqlite_name))


l_ply(files_compress, function(x){  # x <- sample(files_compress, size = 1)
  
  # Check if we load the data in a previous process
  d <- subset(read.table(gzfile(x), nrows =  -1, sep = ",", quote = "\"", header = TRUE), select = pars$logs_col_names)
  file_date <- str_extract(x, "\\d{4}-\\d{2}-\\d{2}")
  start <- as.numeric(strptime(paste(file_date, "00:00:00"), "%Y-%m-%d %H:%M:%S"))
  end <- as.numeric(strptime(paste(file_date, "23:59:59"), "%Y-%m-%d %H:%M:%S"))
  
  if(nrow(dbGetQuery(db, "SELECT name FROM sqlite_master WHERE type='table' AND name='rstudio_logs'"))==0){
    db_nrow <- 0
  } else {
    db_nrow <- dbGetQuery(db, sprintf("select count(*) from rstudio_logs where timestamp >= %s and timestamp <= %s", start, end))  
  }

  if(db_nrow == 0){
    
    # Creating timestamp
    d$timestamp <- as.numeric(strptime(paste(d$date, d$time), "%Y-%m-%d %H:%M:%S"))
    # d$date_revert <- format(as.POSIXct(d$timestamp, tz = "GMT", origin = "1970-01-01"), "%Y-%m-%d")
    # d$time_revert <- format(as.POSIXct(d$timestamp, tz = "GMT", origin = "1970-01-01"), "%H:%M:%S")
    d <- subset(d, select = c("timestamp", "package", "country"))
    
    dbWriteTable(db, name = "rstudio_logs", value = d, append = TRUE)
    message(sprintf("File %s, rows %s", x, prettyNum(nrow(d), big.mark =  ".")))
    
  } else {
    message(sprintf("File %s, rows %s, rows in db %s, NOT uploaded", x, prettyNum(nrow(d), big.mark =  "."), prettyNum(db_nrow, big.mark = "."))) 
  }
    
}, .progress="text")



# test <- dbGetQuery(db, "select *, datetime(timestamp, 'unixepoch', 'localtime') as datetime_timestamp_sqlite, date(timestamp, 'unixepoch', 'localtime') as date_timestamp_sqlite, time(timestamp, 'unixepoch', 'localtime') as time_timestamp_sqlite from rstudio_logs")
# test$date_time <- format(as.POSIXct(test$timestamp, tz = "", origin = "1970-01-01"), "%Y-%m-%d %H:%M:%S")
# test$date <- format(as.POSIXct(test$timestamp, tz = "", origin = "1970-01-01"), "%Y-%m-%d")
# head(test)
# str(test)
# 
# sum(files_counts$file_n)
# 
# test2 <- test[!test$date_time == test$datetime_timestamp_sqlite,]
# head(test2)
# 
# sqlite_count2 <- ddply(test, .(date), summarize, sqlite2_n = length(date))
# sqlite_count <- dbGetQuery(db, "select date(timestamp, 'unixepoch', 'localtime') as date, count(*) as sqlite_n from rstudio_logs group by date(timestamp, 'unixepoch', 'localtime')")
# files_counts2 <- ldply(files_compress, function(x){
#   data.frame(date = file_date <- str_extract(x, "\\d{4}-\\d{2}-\\d{2}"),
#              files_n2 = nrow(read.table(gzfile(x), nrows =  -1, sep = ",", quote = "\"", header = TRUE)))
# }, .progress="text")
# 
# test_f <- join(sqlite_count, sqlite_count2, type = "full")
# test_f <- join(test_f, files_counts, type = "full")
# test_f <- join(test_f, files_counts2, type = "full")
# test_f <- test_f[order(test_f$date), ]
# View(test_f)

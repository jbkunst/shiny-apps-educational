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


if(nrow(dbGetQuery(db, "SELECT name FROM sqlite_master WHERE type='table' AND name='rstudio_logs'"))==0){
  sqlite_content <- data.frame(date = character(), n = integer())
} else {
  sqlite_content <- dbGetQuery(db, "select date(timestamp, 'unixepoch', 'localtime') as date, count(*) as n from rstudio_logs group by date(timestamp, 'unixepoch', 'localtime')")
}


l_ply(files_compress, function(x){  # x <- sample(files_compress, size = 1) # x <- "../data_raw/2014-08-16.csv.gz"
  
  # Load data
  d <- subset(read.table(gzfile(x), nrows =  -1, sep = ",", quote = "\"", header = TRUE), select = pars$logs_col_names)
  file_date <- str_extract(x, "\\d{4}-\\d{2}-\\d{2}")
  match_exist <- suppressMessages(nrow(match_df(sqlite_content, data.frame(date = file_date, n = nrow(d)))) == 1)
  
  if( match_exist ) {
    
    message(sprintf("File <<%s>> is already in db", basename(x)))
    
  } else if ( file_date %in% sqlite_content$date & !match_exist ) {
    
    message(sprintf("File <<%s>> is already in db but nrows differs :S, reuploading", basename(x)))
    
    start <- as.numeric(strptime(paste(file_date, "00:00:00"), "%Y-%m-%d %H:%M:%S"))
    end <- as.numeric(strptime(paste(file_date, "23:59:59"), "%Y-%m-%d %H:%M:%S"))
    dbSendQuery(db, sprintf("delete from rstudio_logs where timestamp >= %s and timestamp <= %s", start, end))
    
    d$timestamp <- as.numeric(strptime(paste(d$date, d$time), "%Y-%m-%d %H:%M:%S"))
    d <- subset(d, select = c("timestamp", "package", "country"))
    
    dbWriteTable(db, name = "rstudio_logs", value = d, append = TRUE)
    message(sprintf("File <<%s>> rows uploaded %s", basename(x), prettyNum(nrow(d), big.mark =  ".")))
      
  } else if (!file_date %in% sqlite_content$date ) {
    
    # Creating timestamp
    d$timestamp <- as.numeric(strptime(paste(d$date, d$time), "%Y-%m-%d %H:%M:%S"))
    d <- subset(d, select = c("timestamp", "package", "country"))
    
    dbWriteTable(db, name = "rstudio_logs", value = d, append = TRUE)
    message(sprintf("File <<%s>>. Rows uploaded %s", basename(x), prettyNum(nrow(d), big.mark =  ".")))
    
  }
   
}, .progress="text")



sqlite_counts <- dbGetQuery(db, "select date(timestamp, 'unixepoch', 'localtime') as date, count(*) as sqlite_n from rstudio_logs group by date(timestamp, 'unixepoch', 'localtime')")
files_counts <- ldply(files_compress, function(x){
  data.frame(date = str_extract(x, "\\d{4}-\\d{2}-\\d{2}"),
             files_n = nrow(read.table(gzfile(x), nrows =  -1, sep = ",", quote = "\"", header = TRUE)))
  }, .progress="text")
test <- join(sqlite_counts, files_counts, type = "full")
test$diff <- test$files_n - test$sqlite_n
View(test)

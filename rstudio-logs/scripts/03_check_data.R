source("00_parameters_and_packages.R")


files_compress <- dir(path = pars$folder_data_raw, full.names = TRUE)
files_compress <- files_compress[file.info(files_compress)$size != 0]
files_compress <- files_compress[!grepl("2012-\\d{2}-\\d{2}.csv.gz$", files_compress)]

db <- dbConnect(SQLite(), dbname = file.path(pars$folder_data_app, pars$file_sqlite_name))

sqlite_counts <- dbGetQuery(db, "select date(timestamp, 'unixepoch', 'localtime') as date, count(*) as sqlite_n from rstudio_logs group by date(timestamp, 'unixepoch', 'localtime')")

files_counts <- ldply(files_compress, function(x){
  data.frame(date = str_extract(x, "\\d{4}-\\d{2}-\\d{2}"),
             files_n = nrow(read.table(gzfile(x), nrows =  -1, sep = ",", quote = "\"", header = TRUE)))
}, .progress="text")

test <- join(sqlite_counts, files_counts, type = "full")
test$diff <- test$files_n - test$sqlite_n

View(test)
source("00_parameters_and_packages.R")


suppressWarnings(dir.create(pars$folder_data_app))


files_compress <- dir(path = pars$folder_data_raw, full.names = TRUE)
files_compress <- files_compress[file.info(files_compress)$size != 0]
# files_compress <- sample(files_compress, size = 20)


try(file.remove(file.path(pars$folder_data_app, pars$file_sqlite_name)))
db <- dbConnect(SQLite(), dbname = file.path(pars$folder_data_app, pars$file_sqlite_name))


data <- l_ply(files_compress, function(x){  # x <- sample(files_compress, size = 1) # x <- "../data_raw/2014-08-16.csv.gz"
  
  # Load data
  d <- read.table(gzfile(x), nrows =  -1, sep = ",", quote = "\"", header = TRUE)
  d <- ddply(d, .(date, package, country), summarise, n = length(package))
  d$timestamp <- as.numeric(strptime(paste(d$date, "00:00:00"), "%Y-%m-%d %H:%M:%S"))
  #  d$revert <- format(as.POSIXct(d$timestamp, tz = "GMT", origin = "1970-01-01"), "%Y-%m-%d")
  #  head(d)
  d <-subset(d, select = c(timestamp, package, country, n))
  dbWriteTable(conn = db, name = "rstudio_logs_aux", value = d, append = TRUE)
  
}, .progress="text")
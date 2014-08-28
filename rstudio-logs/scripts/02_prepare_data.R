source("00_parameters_and_packages.R")


suppressWarnings(dir.create(pars$folder_data_app))


files_compress <- dir(path = pars$folder_data_raw, full.names = TRUE)
files_compress <- files_compress[file.info(files_compress)$size != 0]
# files_compress <- files_compress[!grepl("2012-\\d{2}-\\d{2}.csv.gz$", files_compress)]

data <- ldply(files_compress, function(x){  # x <- sample(files_compress, size = 1) # x <- "../data_raw/2014-08-16.csv.gz"
  
  # Load data
  d <- read.table(gzfile(x), nrows =  -1, sep = ",", quote = "\"", header = TRUE)
  d <- d %>% group_by(date, package, country) %>% summarise(n = n())
  d
  
}, .progress="text")


data <- data %>% group_by(date, package, country) %>% summarise(n = n()) 


save(data, file = file.path(pars$folder_data_app, "data_app.RData"))
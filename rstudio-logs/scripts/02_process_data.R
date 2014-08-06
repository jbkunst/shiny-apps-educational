rm(list=ls())
library(plyr)

folder_raw <- "../data_raw"
folder_proc <- "../data_proc"
data_cols <- c("date", "time", "package", "country") 

suppressWarnings(dir.create(folder_proc))

files_compress <- dir(path = folder_raw, full.names = TRUE)

files_missing <- setdiff(tools::file_path_sans_ext(dir(path = folder_raw), TRUE),
                         tools::file_path_sans_ext(dir(path = folder_proc), TRUE))

files_to_proc <- files_compress[which(tools::file_path_sans_ext(dir(path = folder_raw), TRUE) %in%  files_missing)]

l_ply(files_to_proc, function(file){ # file <- sample(files_to_proc, size = 1)
  message(file)
  if(is.na(file.info("../data_raw/2014-05-17.csv.gz")$size)){
    message(sprintf("No size for file %s", file))
    return(FALSE)
  } 
  data <- read.table(gzfile(file), nrows =  -1, sep = ",", quote = "\"", header = TRUE)
  data <- subset(data, select = data_cols)
  write.table(data, file = gsub(".gz$", "", gsub(folder_raw, folder_proc, file)), sep = ",", row.names = FALSE, quote = FALSE)
}, .progress = "text")

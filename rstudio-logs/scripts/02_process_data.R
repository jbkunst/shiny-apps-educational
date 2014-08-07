rm(list=ls())
library(plyr)
source("00_parameters.R")


data_cols <- c("date", "time", "package", "country") 

suppressWarnings(dir.create(folder_proc))

files_compress <- dir(path = folder_raw, full.names = TRUE)
files_missing <- setdiff(tools::file_path_sans_ext(dir(path = folder_raw), TRUE),
                         tools::file_path_sans_ext(dir(path = folder_proc), TRUE))

files_to_proc <- files_compress[which(tools::file_path_sans_ext(dir(path = folder_raw), TRUE) %in%  files_missing)]
files_to_proc <- if(length(files_to_proc)!=0) files_to_proc else NULL

l_ply(files_to_proc, function(file){ # file <- sample(files_to_proc, size = 1) # file <- "../data_raw/2014-05-16.csv.gz"
  try(
  write.table(
    subset(
      read.table(gzfile(file), nrows =  -1, sep = ",", quote = "\"", header = TRUE),
      select = data_cols),
    file = gsub(".gz$", "", gsub(folder_raw, folder_proc, file)), sep = ",", row.names = FALSE, quote = FALSE, stringsAsFactors = FALSE)
  , silent = TRUE)
})

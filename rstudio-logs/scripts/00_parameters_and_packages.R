rm(list=ls())
library(plyr)
library(lubridate)
library(stringr)
library(RSQLite)
options(stringsAsFactors = FALSE)


pars <- list(
  folder_data_raw = "../data_raw",
  folder_data_app = "../data_app",
  file_sqlite_name = "database.sqlite",
  logs_col_names = c("date", "time", "package", "country") 
  )

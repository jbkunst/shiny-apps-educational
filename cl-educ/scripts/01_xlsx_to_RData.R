#### Packages ####
rm(list=ls())
library(XLConnect)
library(plyr)


#### xlsx to RData ####
files <- dir("data/", full.names = TRUE, pattern = ".xlsx$")
files



files_psu <- files[grepl("PSU", files)]
d_psu <- ldply(files_psu, function(x){ # x <- sample(files_psu, size = 1)
  wb <- XLConnect::loadWorkbook(x)
  df <- readWorksheet(wb, sheet = "Establecimiento_PSU", header = TRUE)
  message(sprintf("File %s, rows: %s, cols: %s", basename(x), nrow(df), ncol(df)))
  df
})

save(d_psu, file = "../data/d_psu.RData")


files_ren <- files[grepl("Rendimiento", files)]
d_ren <- ldply(files_ren, function(x){
  wb <- XLConnect::loadWorkbook(x)
  df <- readWorksheet(wb, sheet = "Nivel_Rendimiento", header = TRUE)
  message(sprintf("File %s, rows: %s, cols: %s", basename(x), nrow(df), ncol(df)))
  df
})

save(d_ren, file = "../data/d_ren.RData")


files_sim <- files[grepl("Simce4Basico", files)]
d_sim <- ldply(files_sim, function(x){
  wb <- XLConnect::loadWorkbook(x)
  df <- readWorksheet(wb, sheet = "Establecimiento_Simce4Basico", header = TRUE)
  message(sprintf("File %s, rows: %s, cols: %s", basename(x), nrow(df), ncol(df)))
  df
})

save(d_sim, file = "../data/d_sim.RData")


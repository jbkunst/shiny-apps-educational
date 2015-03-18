library(shiny)
library(rCharts)
library(leaflet)
library(dplyr)
library(rvest)
library(tidyr)
library(stringi)

source("utils.R")

data <- download_data()
now <- Sys.time()
save(data, now, file = "data/data.RData")


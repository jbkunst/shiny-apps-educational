library(shiny)
library(rCharts)
library(dplyr)
library(ggplot2)
library(leaflet)
library(rvest)
library(tidyr)

# url_info <- "http://www.sismologia.cl/links/ultimos_sismos.html"
# 
# data <- html(url_info) %>% 
#   html_node("table") %>%
#   html_table()
# 
# dir.create("data")
# save(data, file = "data/data.RData")

load("data/data.RData")
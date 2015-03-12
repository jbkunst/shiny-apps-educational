library(shiny)
library(dplyr)
library(rCharts)
library(ggplot2)
library(leaflet)
library(rvest)
library(tidyr)

url_info <- "http://www.sismologia.cl/links/ultimos_sismos.html"

data <- html(url_info) %>% 
  html_node("table") %>%
  html_table()

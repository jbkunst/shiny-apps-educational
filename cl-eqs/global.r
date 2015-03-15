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
#   html_table() %>% 
#   setNames(c("Fecha_Local", "Fecha_UTC", "Latitud", "Longitud",
#              "Profundidad", "Magnitud", "Agencia", "Referencia_Geográfica")) %>% 
#   mutate(Magnitud = extract_numeric(Magnitud)) %>% 
#   separate(Fecha_Local, into = paste(c("Fecha", "Hora"), "Local", sep = "_"), sep = " ") %>% 
#   separate(Fecha_UTC, into = paste(c("Fecha", "Hora"), "UTC", sep = "_"), sep = " ")

# dir.create("data")
# save(data, file = "data/data.RData")

load("data/data.RData")

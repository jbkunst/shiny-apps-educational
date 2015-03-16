library(shiny)
library(rCharts)
library(plyr)
library(dplyr)
library(ggplot2)
library(leaflet)
library(rvest)
library(tidyr)

# url_info <- "http://www.sismologia.cl/links/ultimos_sismos.html"
# 
# data_url <- html(url_info) %>% 
#   html_node("table") %>%
#   html_table() %>% 
#   setNames(c("Fecha_Local", "Fecha_UTC", "Latitud", "Longitud",

#   mutate(Magnitud = extract_numeric(Magnitud)) %>% 
#   separate(Fecha_Local, into = paste(c("Fecha", "Hora"), "Local", sep = "_"), sep = " ") %>% 
#   separate(Fecha_UTC, into = paste(c("Fecha", "Hora"), "UTC", sep = "_"), sep = " ")
# 
# data_url <- adply(data_url, 1, function(x){ # x <- sample_n(data_url, 1)
#   
#   x$popup_info <- tags$dl(class = "dl-horizontal",
#                           tags$dt("Fecha"), tags$dd(x$Fecha_UTC),
#                           tags$dt("Hora"), tags$dd(x$Hora_UTC),
#                           tags$dt("Magnitud"), tags$dd(x$Magnitud, "Ml"),
#                           tags$dt("Profundidad"), tags$dd(x$Profundidad, "Km"),
#                            tags$dt("Referencia"), tags$dd(x$Referencia_Geográfica)) %>%
#     paste()
#   
#   x
# 
# })
# 
# data_url$Fecha_UTC <- NULL
# data_url$Hora_UTC <- NULL
# data_url$Agencia <- NULL

save(data, file = "data/data.RData")
load("data/data.RData")

mag_max <- max(data_url$Magnitud)
prof_max <- max(data_url$Profundidad)

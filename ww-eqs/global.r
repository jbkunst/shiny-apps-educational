library(shiny)
library(rCharts)
library(plyr)
library(dplyr)
library(ggplot2)
library(leaflet)
library(rvest)
library(tidyr)
library(stringr)

# url_info <- "http://www.iris.washington.edu/seismon/eventlist/index.html"
# 
# data_url <- html(url_info) %>% 
#   html_nodes("li") %>%
#   html_nodes("a") %>% 
#   { cbind(region = html_text(.), link = html_attr(., "href"))} %>% 
#   as.data.frame()
# 
# 
# data_url <- adply(data_url, 1, function(x){ # x <- sample_n(data_url, 1)
# 
#   url <- file.path(dirname(url_info), x$link)
#   
#   data_aux <- html(url) %>% 
#     html_node("table") %>% 
#     html_table(fill = TRUE)
#   
#   data_aux <- cbind.data.frame(x, data_aux)
#   
# }, .progress="text")
# 
# names(data_url) <- tolower(names(data_url))
# names(data_url) <- gsub("\\(.*\\)", "", names(data_url))
# names(data_url) <- gsub("^\\s+|\\s+$", "", names(data_url))
# names(data_url) <- gsub("\\s+", "_", names(data_url))
# 
# data_url <- data_url %>% 
#   separate(date_and_time, into = c("date", "time"), sep = " ") %>% 
#   mutate(date2 = as.Date(date, format = "%d-%B-%Y"),
#          region = str_trim(region))
# 
# 
# data_url <- adply(data_url, 1, function(x){ # x <- sample_n(data_url, 1)
#   
#   x$popup_info <- tags$dl(class = "dl-horizontal",
#                           tags$dt("Date"), tags$dd(x$date2),
#                           tags$dt("Time"), tags$dd(x$time),
#                           tags$dt("Magnitude"), tags$dd(x$mag, "Ml"),
#                           tags$dt("Depth"), tags$dd(x$depthkm, "Km"),
#                           tags$dt("Location"), tags$dd(x$location_map)) %>%
#     paste()
#   
#   x
#   
# }, .progress="text")
# 
# 
# data_url <- data_url %>% tbl_df()

##### SAVE DATA ####
save(data_url, file = "data/data.RData")
load("data/data.RData")

##### GENERATING IU PARAMETERS ####
choices_region <- unique(data_url$region)
mag_max <- max(data_url$mag, na.rm = TRUE)
depth_max <- max(data_url$depthkm, na.rm = TRUE)

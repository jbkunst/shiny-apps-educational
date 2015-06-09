library("rvest")
library("plyr")
library("dplyr")
library("shiny")
library("shinydashboard")
library("leaflet")

url <- "http://neo.sci.gsfc.nasa.gov/"

datalinks <- html(url) %>%
  html_nodes("#slider-nav > div > div > div > h3 > a") %>% 
  ldply(function(e){
    data_frame(name = html_text(e) , link = html_attr(e, "href"))
    }) %>% 
  tbl_df() %>% 
  mutate(link = paste0(url, link))


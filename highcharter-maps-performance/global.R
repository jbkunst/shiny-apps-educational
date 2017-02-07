library(shiny)
library(shinythemes)
library(highcharter)
library(dplyr)
options(shiny.launch.browser = TRUE,
        highcharter.theme = hc_theme_elementary())

geojson <- download_map_data("custom/world-robinson-highres")

data <- get_data_from_map(geojson) %>% 
  select(`hc-key`)

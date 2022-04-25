# library(shiny)
# library(tidyverse)
# library(broom)
# library(metR)
# library(scales)
# library(bslib)
# library(thematic)
# library(risk3r)       # remotes::install_github("jbkunst/risk3r")
# library(geomtextpath) # remotes::install_github("AllanCameron/geomtextpath")
# 
# theme_set(theme_minimal() + theme(legend.position = "bottom"))
# 
# thematic_shiny(font = "auto")
# 
# primary_color <- "#708090"
# 
# theme <-  bs_theme(
#   # bg = "#FBFBFB",
#   # fg = "#1B1B1B",
#   primary = primary_color,
#   base_font = font_google("IBM Plex Sans")
# ) %>%
#   bs_add_rules(".nav-pills, .radio { padding-bottom:10px; }")
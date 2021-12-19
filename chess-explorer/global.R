library(shiny)
library(dplyr)
library(stringr)
library(rchess) # devtools::install_github("jbkunst/rchess")
library(shinyjs)
library(bslib)
library(markdown)

data(chessopenings)

chessopenings <- chessopenings %>% 
  mutate(variant = str_glue("{variant} ({eco})"))


theme_chess <-  bs_theme(
  bg = "#FBFBFB",
  fg = "#1B1B1B",
  primary = "#f0d9b5",
  base_font = font_google("Playfair Display")
)

library("shiny")
library("plyr")
library("dplyr")
library("stringr")
library("stringi")
library("shinyBS")

# devtools::install_github("ebailey78/shinyBS")
# library("gspreadr")

source("utils.R")

KEY_GSS <- "1RvWsr4gBtm7qDs2X2YcvKnQS9JwfaCcHw6M6ITcuELk"

data <- get_data_sample()

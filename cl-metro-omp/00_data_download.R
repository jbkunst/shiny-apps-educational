rm(list = ls())

library("readr")
library("plyr")
library("dplyr")
library("stringr")

if (!file.exists("data")) {
  dir.create("data")
} 

url <- "http://datos.gob.cl/recursos/download/4109"

destfile <- "data/data.zip"

download.file(url, destfile,  method = "libcurl", mode = "wb")

files <- unzip("data/data.zip", list = TRUE)

datanames <- files$Name %>% str_replace_all("^data/|\\.txt$", "")

datafiles <- files$Name %>% file.path("data", .)

unzip("data/data.zip", exdir = "data")

l_ply(datafiles, function(filename){
  # filename <- sample(datafiles, size = 1)
  aux_data <- read_csv(filename)
  aux_name <- str_replace_all(filename, "^data/|\\.txt$", "")
  assign(aux_name, aux_data, envir = .GlobalEnv)
})

save(list = datanames, file = "data/data.RData")

file.remove(datafiles)

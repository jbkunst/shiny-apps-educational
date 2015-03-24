library("readr")
library("dplyr")
library("tidyr")


data <- read_csv("~/../Downloads/MOD15A2_M_LAI_2015-02-01_gs_250x125.SS.CSV") 
head(data)





url2 <- "http://neo.sci.gsfc.nasa.gov/servlet/RenderData?si=1612886&cs=rgb&format=SS.CSV&width=3600&height=1800"
data2 <- read_csv(url2)
head(data2)


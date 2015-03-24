library("dplyr")
library("tidyr")
library("readr")
library("ggplot2")

# devtools::install_github("jrnold/ggthemes")
library("ggthemes")


data <- read_csv("~/../Downloads/MOD15A2_M_LAI_2015-02-01_gs_250x125.SS.CSV") 
names(data)[1] <- "lat"

data_g <- data %>%
  gather(lon, value, -lat) %>%
  filter(value != 99999)
#  mutate(value = ifelse(value == 99999, NA, value))
  

ggplot(data_g) +
  geom_point(aes(lon, lat, color = value)) +
  theme_map()
  
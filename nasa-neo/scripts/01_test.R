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
  geom_point(aes(lon, lat, color = value), size = 5, alpha = .7) +
  theme_map()
  

shiny::runApp(system.file("examples/globe",package="threejs"))


#### globejs ####
library("threejs")
library("maps")
data(world.cities, package="maps")
N <- 20
cities <- world.cities[order(world.cities$pop,decreasing=TRUE)[1:N],]
value  <- 100 * cities$pop / max(cities$pop)

# Set up a color map
col <- heat.colors(10)
col <- col[floor(length(col)*(100-value)/100) + 1]


fs <- dir(system.file("images/", package="threejs"), full.names = TRUE)
f <- sample(fs, size = 1)
f
globejs(img=f, lat=cities$lat, long=cities$long, value=value, color=col, atmosphere=TRUE)

globejs("http://eoimages.gsfc.nasa.gov/images/imagerecords/73000/73909/world.topo.bathy.200412.3x5400x2700.jpg")


setwd("~/r")


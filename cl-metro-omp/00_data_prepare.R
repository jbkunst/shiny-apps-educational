rm(list = ls())

# https://developers.google.com/transit/gtfs/ 

library("plyr")
library("dplyr")
library("stringr")
library("tidyr")
library("ggplot2")

load(file = "data/data.RData")

# fix encoding?
names(routes)[1] <- "route_id"

# extracting metro routes
routes_metro <- routes %>%
  filter(str_detect(route_id, "L\\d{1}")) %>% 
  mutate(route_id = str_replace(route_id, "_V\\d+", ""))

shapes %>% filter(str_detect(shape_id, "^L\\d{1}")) %>% sample_n(10)

shapes_metro <- shapes %>%
  filter(str_detect(shape_id, "L\\d{1}")) %>% 
  mutate(shape_id = str_replace(shape_id, "_V\\d+", "")) %>% 
  separate(shape_id, c("shape_id", "direction"), "-") %>% 
  filter(direction == "I") # simplicity

# Verify?  
ggplot(shapes_metro) +
  geom_path(aes(shape_pt_lon, shape_pt_lat, group = shape_id, color = shape_id))

# Yes?!
save(routes_metro, shapes_metro, file = "data/data_app.RData")

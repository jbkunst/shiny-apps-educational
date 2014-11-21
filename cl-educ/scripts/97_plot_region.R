rm(list=ls())
source("global.r")
library(maptools)
library(ggplot2)

input <- list(region_numero = "5", region_indicator = "area_geografica")

region_map <- readShapePoly(sprintf("data/regiones_shp/r%s.shp", input$region_numero))
region_f <- fortify(region_map)


region_colegios <- colegios %>%
  filter(numero_region == input$region_numero & !is.na(longitud) & longitud!=0) %>%
  select(rbd, dependencia, area_geografica, latitud, longitud)
region_colegios[["value"]] <- region_colegios[[input$region_indicator]]
head(region_colegios)

ggplot() +
  geom_polygon(data=region_f, aes(long, lat, group=group), color="white", fill="transparent") +
  geom_point(data=region_colegios, aes(longitud, latitud, color=value), size = 3, alpha =.5) +
  coord_equal() +
  theme_null() + 
  theme(plot.background = element_rect(fill = "#333333", colour = "#333333"))




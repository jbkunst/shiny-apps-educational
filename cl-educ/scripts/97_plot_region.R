rm(list=ls())
source("global.r")
library(maptools)
library(ggplot2)

input <- list(region_numero = "5")

region_map <- readShapePoly(sprintf("data/regiones_shp/r%s.shp", input$region_numero))
region_f <- fortify(region_map)

ggplot(region_f) +
  geom_polygon(aes(long, lat, group=group), color="white", fill="transparent") +
  coord_equal() +
  theme_null() + 
  theme(plot.background = element_rect(fill = "#333333", colour = "#333333"))


region_colegios <- colegios %>%
  filter(numero_region == input$region_numero & !is.na(longitud) & longitud!=0) %>%
  select(rbd, dependencia, area_geografica, latitud, longitud)
head(region_colegios)

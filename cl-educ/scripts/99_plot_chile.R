library(maptools)
library(ggplot2)
library(plyr)

shp <- readShapePoly("../data/division_regional/division_regional.shp")



shp@data$id <- rownames(shp@data)
head(shp@data)

shp.points <- fortify(shp)
head(shp.points)

shp.df <- join(shp.points, shp@data, by="id")



ggplot(shp.df) + 
  aes(long,lat,group=group,fill=SHAPE_Area) + 
  geom_polygon() +
  geom_path(color="white") +
  coord_equal() +
  scale_fill_brewer("Utah Ecoregion")


foreign::read.dbf("../data/division_regional/division_regional.dbf", as.is = FALSE)

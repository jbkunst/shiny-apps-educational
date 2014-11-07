rm(list=ls())
# install.packages("mvtnorm")
library(mvtnorm)
library(plyr)
library(dplyr)
library(ggplot2)

n <- 5000
m1 <- 5
m2 <- 10
mu <- c(m1+2, m2-2)
sigma <- diag(10, nrow = 2)


data <- data.frame(x = rnorm(n, mean = m1, 2), y = rnorm(n, m2, 2))  %>%
  mutate(z= cbind(x,y) %>% dmvnorm(mu, sigma))


ggplot(data) +
  geom_point(aes(x,y, color=z), size = 10, alpha =.1) +
  scale_colour_gradientn(colours = rainbow(3)) + reuse::theme_null()


# library(reuse)
# plots <- llply(1:100, function(x){ # x <- 30
#   ggplot(data) +
#     geom_point(aes(x,y, color=z), size = 10, alpha =.1) +
#     scale_colour_gradientn(colours = rainbow(x)) + theme_null()
# })
# reuse::save.list.plots.pdf(plots, "test.pdf")



library(maptools)
library(rgeos)
load("data/consolidate_data_clean_app.RData")

head(colegios)
colegios <- colegios %>% filter(numero_region==13 & latitud != 0)
colegios <- join(colegios, d, by = "rbd", match = "first")
head(colegios)
str(colegios)


region_shp <- readShapePoly("data/regiones_shp/r13.shp")

region_f <- fortify(region_shp)
head(region_f)
head(colegios)



ggplot()+ 
  geom_point(data=colegios, aes(longitud, latitud, color=psu_matematica), size = 30, alpha =.01) +
  scale_colour_gradientn(colours = c("red", "blue")) +
  geom_polygon(data=region_f, aes(long,lat,group=group), color="#333333", fill="transparent") + 
  coord_equal() +
  reuse::theme_null()



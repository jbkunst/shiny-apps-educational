rm(list=ls())
library(plyr)
library(dplyr)
load("data/consolidate_data_clean.RData")

#### Colegios choices ####
colegios_choices <- colegios$rbd
colegios_choices_names <- paste(colegios$rbd,
                                "-",
                                colegios$nombre_establecimiento,
                                paste0("(", colegios$nombre_comuna, ")"))
names(colegios_choices) <- colegios_choices_names
names(colegios_choices) <- iconv(names(colegios_choices) , to="ASCII//TRANSLIT") 
names(colegios_choices)

#### Regiones choices ####
head(colegios)
regiones <- colegios %>% select(nombre_region, numero_region) %>% distinct()
regiones_choices <- regiones$numero_region
names(regiones_choices) <- regiones$nombre_region
names(regiones_choices) <- iconv(names(regiones_choices) , to="ASCII//TRANSLIT") 
names(regiones_choices) <- gsub("^CANIA$", "ARAUCANIA", names(regiones_choices))
names(regiones_choices) <- gsub("^ANTARTICA$", "MAGALLANES", names(regiones_choices))
names(regiones_choices)

#### Region Indicator Choices ####
region_indicador_choices <- c("Dependencia" = "dependencia",
                              "Area geografica" = "area_geografica")

#### Indicadores Choices ####
names(d)
indicador_choices <- c("SIMCE Matematicas" = "simce_mate",
                       "SIMCE Lenguaje" = "simce_leng",
                       "PSU Matematicas" = "psu_matematica",
                       "PSU Lenguaje" = "psu_lenguaje")

#### chi ####
library(maptools)
library(ggplot2)
chi_shp <- readShapePoly("data/chile_shp_simplified/cl_regiones_geo.shp")
chi_map <- fortify(chi_shp)
chi_map$id <- as.numeric(chi_map$id)+1

newkey <- data.frame(id=seq(15),newid=c(1,2,3, 4, 5, 6,7,8,9,10,13,14,15,11,12))  
head(chi_map)
chi_map <- left_join(chi_map, newkey)
head(chi_map)
table(chi_map$newid)




save(d, colegios,
     colegios_choices,
     indicador_choices,
     regiones_choices,
     region_indicador_choices,
     chi_map,
     file="data/consolidate_data_clean_app.RData")
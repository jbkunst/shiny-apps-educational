rm(list=ls())
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

#### Indicadores Choices ####
names(d)
indicador_choices <- c("SIMCE Matematicas" = "simce_mate",
                       "SIMCE Lenguaje" = "simce_leng",
                       "PSU Matematicas" = "psu_matematica",
                       "PSU Lenguaje" = "psu_lenguaje")

#### Comparacion ####
misma_region <- c("Todas las regiones")


save(d, colegios,
     colegios_choices,
     indicador_choices,
     regiones_choices,
     file="data/consolidate_data_clean_app.RData")
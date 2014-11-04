rm(list=ls())
load("data/d_app.RData")

# rpc <- read.table("data/Codigo_unico_territorial_regiones-provincias-comunas.txt", header = TRUE, sep = "\t", encoding = "utf-8")

x <- colegios$nombre_comuna
x <- ifelse(grepl("^R\\?O ", x), "RÍO ", x)
x <- ifelse(grepl("^\\?U\\?OA$", x), "ÑUÑOA", x)
x <- ifelse(grepl("^ALHU\\?$", x), "ALHUÉ", x)
x <- ifelse(grepl("^ALTO BIOB\\?O$", x), "ALTO BIOBÍO", x)
x <- ifelse(grepl("^AYS\\?N$", x), "AYSÉN", x)
x <- ifelse(grepl("^COPIAP\\?$", x), "COPIAPÓ", x)
x <- ifelse(grepl("^COLB\\?N$", x), "COLBÚN", x)
x <- ifelse(grepl("^LA UNI\\?N$", x), "LA UNIÓN", x)
x <- ifelse(grepl("^MACHAL\\?$", x), "MACHALÍ", x)
x <- ifelse(grepl("^CHILL\\?N VIEJO$", x), "CHILLÁN VIEJO", x)
x <- ifelse(grepl("^$", x), "", x)

colegios$nombre_comuna <- x
sort(unique(colegios$nombre_comuna[grepl("\\?", colegios$nombre_comuna)]))


colegios$nombre_comuna <-  gsub("(^|[[:space:]])([[:alpha:]])", "\\1\\U\\2",
                                tolower(colegios$nombre_comuna), perl = TRUE)
colegios$nombre_establecimiento <- gsub("(^|[[:space:]])([[:alpha:]])", "\\1\\U\\2",
                                        tolower(colegios$nombre_establecimiento), perl = TRUE)

colegios_choices <- colegios$rbd
colegios_choices_names <- paste(colegios$rbd,
                                "-",
                                colegios$nombre_establecimiento,
                                paste0("(", colegios$nombre_comuna, ")"))
names(colegios_choices) <- colegios_choices_names

names(d)
indicador_choices <- c("SIMCE Matemáticas" = "simce_mate",
                       "SIMCE Lenguaje" = "simce_leng",
                       "PSU Matemáticas" = "psu_matematica",
                       "PSU Lenguaje" = "psu_lenguaje")

save(d, colegios, colegios_choices, indicador_choices, file="data/app_data.RData")
rm(list=ls())
load("data/consolidate_data.RData")

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

x <- colegios$nombre_region
x <- ifelse(grepl("AYS\\?N", x), "AYSÉN", x)
x <- ifelse(grepl("CAN\\?A", x), "CANÍA", x)
x <- ifelse(grepl("R\\?OS$", x), "RÍOS", x)
x <- ifelse(grepl("TARAPAC\\?$", x), "TARAPACÁ", x)
x <- ifelse(grepl("BIOB\\?O", x), "BIOBÍO", x)
x <- ifelse(grepl("VALPARA\\?SO", x), "VALPARAÍSO", x)
x <- ifelse(grepl("ANT\\?RTICA", x), "ANTÁRTICA", x)
colegios$nombre_region <- x
sort(unique(colegios$nombre_region[grepl("\\?", colegios$nombre_region)]))

colegios <- colegios %>%
  mutate(longitud = as.numeric(longitud),
         latitud = as.numeric(latitud))

save(d, colegios, x, file="data/consolidate_data_clean.RData")

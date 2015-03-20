rm(list=ls())
library("rvest")
library("plyr")
library("dplyr")
library("stringr")


str_clean <- . %>% str_trim() %>% str_replace("\\s+", " ")

url_base <- "http://www.camara.cl"
url_diputados <- "http://www.camara.cl/camara/diputados.aspx"

html_diputados <- url_diputados %>% 
  html %>%
  html_nodes(".alturaDiputado") 
  
data_diputados <- ldply(html_diputados, function(x){ # x <- sample(html_diputados, size = 1)[[1]]
  
  email     <- x %>% html_nodes("a") %>% .[[1]] %>% html_node("img") %>% html_attr("alt")
  nombre    <- x %>% html_nodes("a") %>% .[[2]] %>% html_text() %>% str_clean
  url_dip   <- x %>% html_nodes("a") %>% .[[2]] %>% html_attr("href") %>% file.path(url_base, "camara", .)
  region    <- x %>% html_nodes("a") %>% .[[3]] %>% html_text() %>% str_clean %>% str_replace("Región: ", "")
  distrito  <- x %>% html_nodes("a") %>% .[[4]] %>% html_text() %>% str_clean %>% str_replace("Distrito: N°", "")
  partido   <- x %>% html_nodes("a") %>% .[[5]] %>% html_text() %>% str_clean %>% str_replace("Partido: ", "")
  url_foto  <- x %>% html_node(".imgSet img") %>% html_attr("src") %>% file.path(url_base, .)
  
  y <- url_dip %>% html()

  fecha_nac <- y %>% html_nodes(".birthDate p") %>%  html_text() %>% str_clean
  profesion <- y %>% html_nodes(".profession p") %>%  html_text() %>% str_clean
  comunas <- y %>% html_nodes(".summary") %>% .[[1]] %>% html_nodes("p") %>% .[[1]] %>% html_text() %>% str_clean
  comite <- y %>% html_nodes(".summary") %>% .[[3]] %>% html_nodes("p") %>% .[[1]] %>% html_text %>% str_clean
  
  data_frame(nombre, email, partido, region, distrito, url_foto, url_dip,
             fecha_nac, profesion, comunas, comite)  
  
}, .progress="text")

str(data_diputados)

colors <- data_frame(partido = c("UDI", "DC", "PS", "PPD", "RN",
                                 "IND", "PC", "PRSD", "PL"),
                     color = c("#002d71", "#2262aa", "#b70002", "#e9e234", "#743f55",
                               "#eeeeee", "#db2001", "#1da23a", "#ffd700"))

wp <- data_diputados %>%
  group_by(comite, partido) %>% 
  summarise(n=n()) %>% 
  ungroup() %>% 
  left_join(colors, by = "partido") %>% 
  arrange(desc(n)) %>% 
  {waffle(setNames(.$n, .$comite), colors = .$color, rows = 5)} +
  theme(legend.position = "bottom")

  
class(wp)
ggthemes::theme_hc

save(data_diputados, file = "data/data.RData")



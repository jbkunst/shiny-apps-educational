library("shiny")
library("plyr")
library("dplyr")
library("leaflet")
library("rvest")
library("tidyr")
library("DT")

download_data <- function(){
  
  url <- "http://www.sismologia.cl/links/ultimos_sismos.html"
  
  data_url <- html(url) %>% 
    html_node("table") %>%
    html_table()
  
  links <- html(url) %>% 
    html_nodes("a") %>%
    html_attr("href") %>% 
    sprintf("http://www.sismologia.cl%s", .) %>% 
    llply(function(x){ tags$a(href = x, "detalle", target = "_blank") %>% as.character()}) %>% 
    unlist()
  
  names(data_url) <- names(data_url) %>% 
    tolower() %>% 
    gsub(" ", "_", .) %>% 
    gsub("\\[|\\]", "", .)
  
  data_url <- data_url %>% 
    mutate(magnitud = extract_numeric(magnitud),
           link = links) %>% 
    separate(fecha_local, into = c("fecha", "hora"), sep = " ") %>% 
    rename(referencia = referencia_geográfica,
           profundidad = profundidad_km) %>% 
    select(-fecha_utc)
  
  template_pop_up <-  tags$dl(class = "dl-horizontal",
                              tags$dt("Fecha"), tags$dd("%s"),
                              tags$dt("Hora"), tags$dd("%s"),
                              tags$dt("Magnitud"), tags$dd("%s"),
                              tags$dt("Profundidad"), tags$dd("%s"),
                              tags$dt("Referencia"), tags$dd("%s")) %>% paste()
  
  popup_info <- sprintf(template_pop_up,
                        data_url[["fecha"]], data_url[["hora"]],
                        data_url[["magnitud"]], data_url[["profundidad"]],
                        data_url[["referencia"]])
  
  data_url <- data_url %>% mutate(popup_info = popup_info)
  
  data_url
}
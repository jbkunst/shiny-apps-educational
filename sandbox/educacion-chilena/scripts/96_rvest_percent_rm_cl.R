library(rvest)
library(stringr)
library(dplyr)

page <- html("http://es.wikipedia.org/wiki/Anexo:Regiones_de_Chile_por_superficie")

table <- page %>%
  html_node("table") %>%
  html_table()

table <- setNames(table[c(-1, -1*nrow(table)),], table[1,])

names(table) <- tolower(str_extract(names(table), "^\\w+"))


table <- table %>%
  mutate(sup = superficie  %>% 
           str_extract("\\d+?(\\s)\\d+") %>%
           str_replace("\\s+", "")  %>%
           as.numeric)


sup_rm <- table$sup[with(table, which(grepl("Santiago", región)))]
sup_cl <- sum(table$sup)

100*(sup_rm/sup_cl)
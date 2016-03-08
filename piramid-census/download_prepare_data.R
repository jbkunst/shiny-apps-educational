rm(list = ls())
library("idbr") # devtools::install_github('walkerke/idbr')
library("purrr")
library("stringr")
library("rvest")
library("dplyr")
library("highcharter")
library("ggplot2")
library("matrixStats")
library("geojsonio")

dfcodes <- "http://www.geohive.com/earth/gen_codes.aspx" %>% 
  read_html() %>% 
  html_table(fill = TRUE) %>% 
  .[[2]] %>% 
  tbl_df() %>% 
  setNames(str_to_id(names(.))) %>% 
  filter(!is.na(iso_3_letter), iso_3_letter != "")

yrs <- 2000:2020

filename <- "censusdata.rds"

if (file.exists(filename)) {
  
  df <- readRDS(filename)
  
} else {
  
  # http://api.census.gov/
  idb_api_key("35f116582d5a89d11a47c7ffbfc2ba309133f09d")
  
  df <- dfcodes$fips %>% 
    map_df(function(x){
      # x <- sample(dfcodes$fips, size = 1)
      message(x)
      try(return(rbind(
        idb1(x, yrs, sex = "male"),
        idb1(x, yrs, sex = "female")
      )))
      data_frame(FIPS = x)
      
    })
  
  df <- df %>%
    filter(!is.na(time)) %>% 
    mutate(SEX = ifelse(SEX == 1, "male", "female"))
  
  names(df) <- tolower(names(df))
  
  saveRDS(df, "censusdata.rds")
  
}

df
dfcodes

data("worldgeojson")

dfwgj <- map_df(worldgeojson$features, function(x){
  data_frame(
    iso3 = x$properties$iso3,
    namem = x$properties$name
  )
})


# this will conatain median age by country and year to show in the map
df <- df %>% 
  left_join(dfcodes %>% select(fips, iso3 = iso_3_letter, entity), by = "fips") %>% 
  left_join(dfwgj, by = "iso3")

df <- df %>% filter(!is.na(namem))

df2 <- df %>% 
  group_by(iso3, name = namem, time) %>% 
  do({
    data_frame(
      wage = weightedMedian(
        c(.$age[.$sex == "male"], .$age[.$sex == "female"]),
        c(.$pop[.$sex == "male"], .$pop[.$sex == "female"]))
    )
  }) %>% 
  ungroup() %>% 
  mutate(wage = round(wage, 3))
  


# world <- geojsonio::geojson_read("countries.json")
# save(df, df2, df3, yrs, file = "dataapp.RData")

df <- df %>% select(iso3, name = namem, time, pop, age, sex)

save(df,
     df2,
     yrs,
     file = "dataappmin.RData")


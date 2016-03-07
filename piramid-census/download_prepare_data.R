rm(list = ls())
library("idbr") # devtools::install_github('walkerke/idbr')
library("rvest")
library("purrr")
library("stringr")
library("dplyr")
library("highcharter")


data(iso3166, package = "maps")
iso3166 <- tbl_df(iso3166)

yrs <- 2010:2015


# http://api.census.gov/
idb_api_key("35f116582d5a89d11a47c7ffbfc2ba309133f09d")

df <- iso3166$a2 %>% 
  map_df(function(x){
    # x <- sample(iso3166$a2, size = 1)
    message(x)
    try(return(rbind(
      idb1(x, yrs, variables = c("AGE", "NAME"), sex = "male"),
      idb1(x, yrs, variables = c("AGE", "NAME"), sex = "female")
    )))
    data_frame(FIPS=x)
    
  })


saveRDS(df, "censusdata.rds")

df <- df %>%
  filter(!is.na(time))

df %>% count(FIPS, AGE)

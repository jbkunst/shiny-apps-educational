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


# this will conatain median age by country and year to show in the map
df <- df %>% 
  left_join(dfcodes %>% select(fips, iso3 = iso_3_letter), by = "fips") 

df2 <- df %>% 
  group_by(iso3, name, time) %>% 
  do({
    data_frame(
      wage = weightedMedian(
        c(.$age[.$sex == "male"], .$age[.$sex == "female"]),
        c(.$pop[.$sex == "male"], .$pop[.$sex == "female"]))
    )
  })

df2 <- df2 %>% 
  mutate(wage = round(wage, 3))

ggplot(df2) +
  geom_line(aes(time, wage, group = name, color = name), alpha = 0.5) + 
  theme(legend.position = "none")

hctss <- highchart() %>% 
  hc_chart(type = "spline") %>% 
  hc_plotOptions(
    series = list(
      stickyTracking = FALSE,
      marker = list(enabled = FALSE),
      showInLegend = FALSE,
      events = list(
        mouseOver = JS("function(){ this.update({color: 'red'})}"),
        mouseOut = JS("function(){ this.update({color: '#CCC'}) }")
      )
  )) %>% 
  hc_xAxis(categories = yrs) 
  
for (isoc in (unique(df$iso3))) {
  
  hctss <- hctss %>% 
    hc_add_series(data = df2 %>% filter(iso3 == isoc) %>% .$wage,
                  color = "#CCC",
                  name = dfcodes %>% filter(iso_3_letter == isoc) %>% .$entity,
                  iso3 = isoc)
}

hctss
  

# this is a summary from df whe grouped age
ageb <- c(seq(0, 100, by = 5))

df3 <- df %>% 
  mutate(agec = cut(age, breaks = ageb, include.lowest = TRUE)) %>% 
  group_by(iso3, name, time, sex, agec) %>% 
  summarise(pop = sum(pop)) %>% 
  ungroup()

# world <- geojsonio::geojson_read("countries.json")
# save(df, df2, df3, yrs, file = "dataapp.RData")

df <- df %>% select(-area_km2, -name, -fips)

save(df,
     df2,
     #df3,
     hctss,
     dfcodes,
     yrs,
     file = "dataappmin.RData")


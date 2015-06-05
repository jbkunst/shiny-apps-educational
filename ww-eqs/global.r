library("shiny")
library("leaflet")
library("dplyr")
library("rvest")
library("tidyr")
library("stringi")
library("stringr")
library("DT")

download_data <- function(){
  
  message(sprintf("%s: %s", Sys.time(), "Downloading data"))
  
  url <- "http://ds.iris.edu/seismon/eventlist/index.phtml"
  
  data <- html(url) %>% 
    html_node("table") %>% 
    html_table(fill = TRUE) %>% 
    tbl_df()
  
  names(data) <- tolower(names(data))
  names(data) <- gsub("\\(.*\\)", "", names(data))
  names(data) <- stri_trim(names(data))
  names(data) <- str_replace_all(names(data), "\\s+", "_")
  names(data)[7] <- "event_id"
  
  data <- data %>% 
    separate(date_and_time, into = c("date", "time"), sep = " ") %>% 
    mutate(date = as.Date(date, format = "%d-%B-%Y")) %>%
    rename(depth = depthkm,
           magnitude = mag,
           latitude = lat,
           longitude = lon,
           location = location_map,
           event = event_id) %>%
    mutate(event = str_trim(event),
           location = stri_trans_totitle(location),
           size = (magnitude^2)*7500) # this need some justifactions)
  
  template_pop_up <-  tags$dl(class = "dl-horizontal",
                              tags$dt("Date"), tags$dd("%s"),
                              tags$dt("Time"), tags$dd("%s"),
                              tags$dt("Magnitude"), tags$dd("%s"),
                              tags$dt("Depth"), tags$dd("%s"),
                              tags$dt("Location"), tags$dd("%s")) %>% paste()
  
  popup_info <- sprintf(template_pop_up,
                        data[["date"]], data[["time"]],
                        data[["magnitude"]], data[["depth"]],
                        data[["location"]])
  
  template_event <-  tags$a(href=sprintf("http://ds.iris.edu/ds/nodes/dmc/tools/event/%s",
                                         "%s"), "%s", target="_blank") %>% paste()
  
  event_info <- sprintf(template_event, data[["event"]], data[["event"]])
  
  data <- data %>%
    mutate(popup_info = popup_info,
           event = event_info)
  
  data
  
}


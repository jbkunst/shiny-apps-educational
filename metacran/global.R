rm(list = ls())
library("plyr")
library("dplyr")
library("stringr")

# http://stackoverflow.com/questions/5364264/how-to-control-the-igraph-plot-layout-with-fixed-positions/5364376#5364376
#

download_data <- function(){
  
  url <- "https://raw.githubusercontent.com/metacran/PACKAGES/master/PACKAGES"
  
  txt <- readLines(url)

  cuts <- data_frame(start = c(0, which(txt == "") + 1),
                     end = c(which(txt == "") - 1, length(txt)))

  data <- ldply(seq(nrow(cuts)), function(id){ # id <- sample(seq(nrow(cuts)), size = 1)
    
    cut <- cuts[id,]
    tx <- paste(txt[cut$start:cut$end], collapse = " ")
    
    values <- str_split(tx, "\\w+:") %>% unlist() %>% str_trim() %>% .[-1]
    keys <- str_extract_all(tx, "\\w+:") %>% unlist() %>% str_trim() %>% str_replace(":", "")
    
    d <- data.frame(t(values), stringsAsFactors = FALSE) %>% setNames(keys)
    
    d
  }, .progress = "text")
  
  data <- tbl_df(data)
  
  names(data) <- tolower(names(data))
  
  data
  
  #### edges
  
  edges <- data %>% 
    group_by(package) %>% 
    do(as.data.frame(.$depends %>%
                       str_split(",") %>%
                       unlist() %>%
                       str_trim(), stringsAsFactors = FALSE) %>%
         setNames("depend")) %>% 
    ungroup()
  
  edges <- edges %>%
    mutate(depend = str_replace_all(depend, "\\(.*\\)", ""),
           depend = str_trim(depend)) %>% 
    filter(depend != "R") %>% 
    filter(depend != "") %>% 
    arrange(package)
  
  names(edges) <- c("target", "source")
  
#   pkg <- sample(data$package, size = 1)
#   data %>% filter(package == pkg) %>% select(package, depends)
#   edges %>% filter(package == pkg)
}

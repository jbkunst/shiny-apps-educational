rm(list = ls())
library(shiny)
library(shinythemes)
library(dplyr)
library(purrr)
library(markdown)
library(jpeg)
library(tidyr)

library(threejs) # devtools::install_github("bwlewis/rthreejs")

# options(shiny.launch.browser = TRUE)

str_capitalize <- function(string){
  # http://stackoverflow.com/questions/6364783/capitalize-the-first-letter-of-both-words-in-a-two-word-string/6365349#6365349
  gsub("(^|[[:space:]])([[:alpha:]])", "\\1\\U\\2", tolower(string), perl=TRUE)
}

img_choices <- setNames(dir("imgs/", full.names = TRUE),
                        str_capitalize(gsub("\\.jpg$|\\.jpeg$|", "", dir("imgs/"))))


matrix_to_df <- function(m) {
  # m <- matrix(round(runif(12), 2), nrow = 4)
  m %>% 
    as.data.frame() %>% 
    tbl_df() %>% 
    mutate(y = seq_len(nrow(.))) %>% 
    gather(x, c, -y) %>% 
    mutate(
      x = as.numeric(gsub("V", "", x)),
      y = rev(y)
      ) %>% 
    select(x, y, c)
  
}

rotate_m <- function(m) {
  mr <- m[rev(1:nrow(m)),]
  mr <- t(mr)
  mr
}

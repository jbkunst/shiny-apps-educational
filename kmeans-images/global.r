library(shiny)
library(dplyr)
library(jpeg)
library(reshape)
library(ggplot2)
library(scales)
library(threejs)

str_capitalize <- function(string){
  # http://stackoverflow.com/questions/6364783/capitalize-the-first-letter-of-both-words-in-a-two-word-string/6365349#6365349
  gsub("(^|[[:space:]])([[:alpha:]])", "\\1\\U\\2", tolower(string), perl=TRUE)
}

theme_gg_custom <- function(){
  theme(axis.line = element_line(colour = "black"),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_blank(),
        panel.background = element_blank()) 
}
  

img_choices <- setNames(dir("imgs/", full.names = TRUE),
                        gsub("\\.jpg$|\\.jpeg$|", "", dir("imgs/")) %>% str_capitalize)


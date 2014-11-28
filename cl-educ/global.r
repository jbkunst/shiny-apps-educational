library(shiny)
library(rCharts)
library(plyr)
library(dplyr)
library(ggplot2)
library(scales)
library(maptools)
library(grid)

load("data/consolidate_data_clean_app.RData")

theme_null <- function() {
  theme(axis.line = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks = element_blank(),
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        legend.position = "none",
        panel.background = element_blank(),
        panel.border = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_blank())
}

theme_legend <- function(){
  theme(legend.position = "bottom",
        text=element_text(colour = "white"),
        legend.background = element_rect(fill = "transparent"),
        legend.text = element_text(size = 10),
        legend.key.size = unit(0.8, "cm"))
}

library("shiny")
library("htmlwidgets")
library("d3wordcloud")
library("tm")
library("dplyr")
library("ggthemes")

load("data.RData")

choices_font <- c("Open Sans", "Lato", "Raleway", "Comic Sans MS (No plz!)" = "Comic Sans MS",
                  "Erica One", "Anton", "Arial", "Arial Black", "Tahoma", "Verdana", "Courier New",
                  "Georgia", "Times New Roman", "Andale Mono")

colors <- c(ggthemes_data$hc$palettes$default,
            ggthemes_data$hc$palettes$darkunica,
            ggthemes_data$fivethirtyeight,
            ggthemes_data$economist)
colors <- sample(colors)
colors <- substr(colors, 0, 7)




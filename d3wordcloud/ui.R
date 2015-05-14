library("shiny")
library("d3wordcloud")
library("htmlwidgets")
library("dplyr")
library("rvest")
library("tm")

shinyUI(
  fluidPage(
    tags$link(rel = "stylesheet", type = "text/css", href = "https://bootswatch.com/paper/bootstrap.css"),
    tags$br(),
    fluidRow(
      column(width = 4, class = "well",
             selectInput("url", label = "URL:",
                         choices = c("http://en.wikipedia.org/wiki/R_(programming_language)",
                                     "http://www.htmlwidgets.org/develop_intro.html",
                                     "http://r-pkgs.had.co.nz/intro.html")),
             sliderInput("n_words", label = "Number of words:", min = 10, max = 500, step = 10, value = 200),
             selectInput("font", label = "Font:",
                         choices = c("Impact", "Comic Sans MS (No plz!)" = "Comic Sans MS",
                                     "Arial", "Arial Black", "Tahoma", "Verdana", "Courier New",
                                     "Georgia", "Times New Roman", "Andale Mono")),
             sliderInput("padding", label = "Padding:", min = 0, max = 5, value = 1, step = 1),
             sliderInput("scale", label = "Scale:", min = 0, max = 5, value = 1, step = 1),
             sliderInput("rotate", label = "Rotate:", min = -90, max = 90, value = c(0, 45), step = 5)
      ),
      column(width = 8,
             d3wordcloudOutput("d3wc")
      )
    )
  )
)
library("shiny")
library("htmlwidgets")
library("d3wordcloud")
library("dplyr")
library("rvest")
library("tm")

load("data.RData")

shinyUI(
  fluidPage(
    tags$link(rel = "stylesheet", type = "text/css", href = "https://bootswatch.com/paper/bootstrap.css"),
    tags$br(),
    fluidRow(
      column(width = 4, class = "well",
             selectInput("url", label = "URL:",
                         choices = names(corpus_data)),
             sliderInput("n_words", label = "Number of words:", min = 10, max = 500, step = 10, value = 200),
             selectInput("font", label = "Font:",
                         choices = c("Impact", "Comic Sans MS (No plz!)" = "Comic Sans MS",
                                     "Arial", "Arial Black", "Tahoma", "Verdana", "Courier New",
                                     "Georgia", "Times New Roman", "Andale Mono")),
             sliderInput("padding", label = "Padding:", min = 0, max = 5, value = 1, step = 1),
             sliderInput("rotate", label = "Rotate:", min = -90, max = 90, value = c(0, 45), step = 5),
             p(class = "pull-right small",
               "Code by ", a(href = "http://jkunst.com", "Joshua Kunst", target = "_blank"),
               " | Package ", a(href = "https://github.com/jbkunst/d3wordcloud", "d3wordcloud", target = "_blank"),
               " | Repo here ",
               a(href = "https://github.com/jbkunst/shiny-apps/tree/master/d3wordcloud", icon("github"), target = "_blank")
             )
      ),
      column(width = 8,
             d3wordcloudOutput("d3wc")
      )
    )
  )
)
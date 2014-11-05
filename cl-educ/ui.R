library(shiny)
library(rCharts)
library(maptools)
library(ggplot2)
library(plyr)
library(dplyr)
devtools::source_url("https://raw.githubusercontent.com/jbkunst/reuse/master/R/gg_themes.R")

load("data/app_data.RData")

shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
      ),
    fluidRow(
      column(width = 12, id = "menu",
             h2(id="title", "¿Cómo va mi colegio?"),
             br(),
             tabsetPanel(type = "pills",
               tabPanel("País",
                        h2("plot")
                        ),
               tabPanel("Región",
                        h2("bla")
                        ),
               tabPanel("Colegio",
                        column(width = 4,
                               selectInput("colegio_rbd", NULL, colegios_choices, width="90%"),
                               selectInput("indicador", NULL, indicador_choices, width="90%"),
                               br(),
                               selectInput("otra", NULL, indicador_choices, width="90%"),
                               selectInput("otra1r", NULL, indicador_choices, width="90%")
                               ),
                        column(width = 8,
                               includeScript("www/js/hc_custom.js"),
                               chartOutput("rank_plot", "highcharts"),
                               htmlOutput("rank_text")
                               )
                        ),
               tabPanel("Acerca de",
                        h2("bla")
                        )
               )
             )
      )
    )
  )
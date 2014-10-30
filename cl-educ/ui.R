library(shiny)
library(rCharts)
library(maptools)
library(ggplot2)
library(plyr)
library(dplyr)

load("data/colegios.RData")

shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
      ),
    fluidRow(
      column(width = 10, id = "menu",
             h2("¿Ćomo va mi colegio?"),
             selectInput("colegio_rbd", NULL, colegios_choices, width="100%"),
             selectInput("indicador", NULL, indicador_choices, width="100%"),
            
             includeScript("www/hc_custom.js"),
             chartOutput("plot", "highcharts")

             ),
      column(width = 2, id = "menu",
             plotOutput("map_chile")
             )
      )
    )
  )
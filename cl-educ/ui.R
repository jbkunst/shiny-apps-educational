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
      column(width = 6, id = "menu",
             h2("¿Cómo va mi colegio?"),
             
             # Controls
             selectInput("colegio_rbd", NULL, colegios_choices, width="100%"),
             selectInput("indicador", NULL, indicador_choices, width="100%"),
             # Content
             includeScript("www/js/hc_custom.js"),
             chartOutput("rank_plot", "highcharts"),
             htmlOutput("rank_text")
             )
      )
    )
  )
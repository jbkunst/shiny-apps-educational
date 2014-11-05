library(shiny)
library(rCharts)
library(maptools)
library(ggplot2)
library(plyr)
library(dplyr)
# devtools::source_url("https://raw.githubusercontent.com/jbkunst/reuse/master/R/gg_themes.R")

load("data/app_data.RData")

shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
      ),
    fluidRow(
      column(width = 12, id = "menu",
             h2(id="title", "Pone Título Aquí"),
             br(),
             tabsetPanel(type = "pills", selected = "Colegio",
               tabPanel("País",
                        h2("plot")
                        ),
               tabPanel("Región",
                        h2("bla")
                        ),
               tabPanel("Colegio",
                        column(width = 4,
                               selectizeInput("colegio_rbd", NULL, colegios_choices, width="90%"),
                               selectizeInput("indicador", NULL, indicador_choices, width="90%"),
                               hr(),
                               tags$small(paste(
                                 "Nota: Puedes comparar el colegio seleccionado",
                                 "considerando los colegios con características similares",
                                 "tales como region, dependencia, etc."
                               )),
                               br(), br(),
                               selectizeInput("otra", NULL, indicador_choices, width="90%"),
                               selectizeInput("otra1r", NULL, indicador_choices, width="90%")
                               ),
                        column(width = 8,
                               includeScript("www/js/hc_custom.js"), 
                               chartOutput("rank_plot", "highcharts"),
                               htmlOutput("rank_text"),
                               br()
                               )
                        ),
               tabPanel("Acerca de",
                        column(width = 6,
                               includeMarkdown("report/acerca.md")
                               )
                        )
               )
             )
      )
    )
  )
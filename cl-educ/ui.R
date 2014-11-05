library(shiny)
library(rCharts)
library(plyr)
library(dplyr)
library(scales)
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
             tabsetPanel(type = "pills", selected = "COLEGIO",
               tabPanel("PAÍS",
                        p("plot asd asdasda sdasdas")
                        ),
               tabPanel("REGIÓN",
                        p("bla asd asdfasd fasdfasdf asdf ")
                        ),
               tabPanel("COLEGIO",
                        column(width = 4,
                               selectizeInput("colegio_rbd", NULL, colegios_choices, selected = 10726, width="90%"),
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
                               chartOutput("plot_colegio", "highcharts"),
                               br(),
                               uiOutput("report_colegio"),
                               br()
                               )
                        ),
               tabPanel("ACERCA DE",
                        column(width = 6,
                               includeMarkdown("report/acerca.md")
                               )
                        )
               )
             )
      )
    )
  )
require(shiny)
require(rCharts)

shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
      ),
    fluidRow(
      column(width = 3, id = "menu",
             h2("Analisis Modelos Behavior"),
             radioButtons(inputId = "g_variable", label = "Group by",
                          choices = list( "Cyl" = "cyl", "VS" = "vs", "AM" = "am", "Gear" = "gear"),
                          selected = "area"
                          )
             ),
      column(width = 9, id = "menu",
             includeScript("www/hc_custom.js"),
             chartOutput("plot", "highcharts")
             )
      )
    )
  )
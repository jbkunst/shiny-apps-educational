require(shiny)
require(rCharts)

shinyUI(fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "http://bootswatch.com/superhero/bootstrap.min.css")
  ),
  titlePanel("Migrations Analysis"),
  sidebarLayout(
    sidebarPanel(
      radioButtons(
        inputId = "g_variable",
        label = "Group by",
        choices = list( "Cyl" = "cyl",
                        "VS" = "vs",
                        "AM" = "am",
                        "Gear" = "gear"),
        selected = "area"
      )
    ),
    mainPanel(
      chartOutput("plot", "highcharts")
    )
  )
))
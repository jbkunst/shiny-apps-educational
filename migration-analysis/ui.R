require(shiny)
require(rCharts)

# input <- list()
# input$destination_selector <- "Chile"
# input$origin_selector <- c("Argentina", "Mexico")
load("data/master_data.RData")

# runApp("../shiny_migration/")
shinyUI(fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "http://bootswatch.com/superhero/bootstrap.min.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "custom.css"),
    tags$link(type = "text/javascript", src = "highcharts/js/highcharts.js"),
    tags$link(type = "text/javascript", src = "http://www.highcharts.com/js/themes/dark-unica.js"),
    tags$link(type = "text/javascript", src = "custom.js")
  ),
  titlePanel("Migrations Analysis"),
  sidebarLayout(
    sidebarPanel(
      selectizeInput(
        inputId = "destination_selector", label = "Destination", choices = unique(data$cntdest_label), multiple = FALSE, selected = "United States"
      ),
      selectizeInput(
        inputId = "origin_selector", label = "Origin", choices = unique(data$cntorg_label), multiple = TRUE, selected = c("Mexico", "China", "India")
      ),
      radioButtons(
        inputId = "plot_type", label = "Plot type",
        choices = list( "Area Stacked" = "area", "Percent Stacked" = "area_percent", "Lines" = "line"), selected = "area"
      )
    ),
    mainPanel(
      tabsetPanel(
        id = 'panel',
        tabPanel('Plot', chartOutput("plot", "highcharts")),
        tabPanel('Map', chartOutput("map", "datamaps")),
        tabPanel('Table', dataTableOutput('table')),
        tabPanel('Inputs', verbatimTextOutput('log'))
      )
    )
  ),
  fluidRow(
    column(width = 12, class="text-right footer well navbar-fixed-bottom",
           paste(strong(a("Jkunst.com", href="jkunst.com")), format(Sys.time(), "%Y"), "| Shiny Powered")
    )
  )
))
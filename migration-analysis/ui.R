require(shiny)
require(rCharts)

# input <- list()
# input$destination_selector <- "Chile"
# input$origin_selector <- c("Argentina", "Mexico")
# runApp("../migration-analysis/")
load("data/master_data.RData")

shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "http://bootswatch.com/superhero/bootstrap.min.css")
      ),
    br(),
    sidebarLayout(
      sidebarPanel(
        h3("Migrations Analysis"),
        selectInput(
          inputId = "destination_selector", label = "Destination", choices = unique(data$cntdest_label), multiple = FALSE, selected = "United States", width = "100%"
          ),
        selectInput(
          inputId = "origin_selector", label = "Origin", choices = unique(data$cntorg_label), multiple = TRUE, selected = c("Mexico", "China", "India"), width = "100%"
          ),
        radioButtons(
          inputId = "plot_type", label = "Plot type",
          choices = list( "Area Stacked" = "area", "Percent Stacked" = "area_percent"), selected = "area"
          )
        ),
      mainPanel(
        tabsetPanel(
          id = 'panel',
          tabPanel('Plot', chartOutput("plot", "highcharts"), tags$script(src="custom-dark-unica.js", type='text/javascript')),
          tabPanel('Map', chartOutput("map", "datamaps")),
          tabPanel('Table', dataTableOutput('table'))
          )
        )
      ),
    fluidRow(
      column(width = 12, class="footer well navbar-fixed-bottom", id ="footer",
        column(width = 6,
          p("Shiny Powered")
          ),
        column(width = 6,
          p(class="text-right", strong(a("Jkunst.com", href="http://jkunst.com", target = "_blank")), paste(format(Sys.time(), "%Y")))
          )
        )
      )
    )
)
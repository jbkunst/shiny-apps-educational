fluidPage(
  theme = shinytheme("paper"),
  fluidRow(
    column(6, selectInput("package", "Package",
                          c("highcharter", "rbokeh", "plotly", "metricsgraphics"))),
    column(6, numericInput("ncharts", "Charts", value = 4, min = 1, max = 10))
    ),
  fluidRow(htmlOutput("charts"))
  )

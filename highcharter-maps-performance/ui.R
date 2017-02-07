fluidPage(
  theme = shinytheme("paper"),
  tags$script(src = "https://code.highcharts.com/mapdata/custom/world-robinson-highres.js"),
  fluidRow(
    column(
      12,
      selectInput("sel", NULL, c("Preloaded map" = "preload", "Sending map" = "send")),
      actionButton("action", "Generate map")
      )
    ),
  fluidRow(column(12, highchartOutput("hcmap")))
  )
  

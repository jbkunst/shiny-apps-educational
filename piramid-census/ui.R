shinyUI(
  fluidPage(theme = "css/custom.css",
    fluidRow(
      column(12, sliderInput("yr", NULL, value = min(yrs), min = min(yrs), max = max(yrs),
                             round = TRUE, ticks = FALSE, step = 1, width = "100%",
                             animate = animationOptions(interval = 1000)))
    ),
    fluidRow(
      column(12, highchartOutput("hcworld")),
      column(6, highchartOutput("hcpopiramid")),
      column(6, highchartOutput("hctss"))
      ) 
  
))

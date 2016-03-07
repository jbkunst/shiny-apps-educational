shinyUI(
  fluidPage(
    fluidRow(
      column(12, sliderInput("yr", NULL, value = min(yrs), min = min(yrs), max = max(yrs),
                             round = TRUE, ticks = FALSE, step = 1, width = "100%",
                             animate = animationOptions(interval = 500)))
    ),
    fluidRow(
      column(6, highchartOutput("hcworld")),
      column(6, highchartOutput("hcpopiramid")),
      column(12, highchartOutput("hctss"))
      ) 
  
))

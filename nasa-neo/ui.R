library("shiny")
library("threejs")

shinyUI(fluidPage(
  sidebarLayout(
    sidebarPanel(
      sliderInput("N", "Number of cities to plot", value=1000, min = 100, max = 10000, step = 100),
      hr(),
      p("Use the mouse zoom to zoom in/out."),
      p("Click and drag to rotate.")
    ),
    mainPanel(
      globeOutput("globe")
    )
  )
))

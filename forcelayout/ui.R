shinyUI(fluidPage(
  
  titlePanel("Shiny networkD3 "),
  
  sidebarLayout(
    sidebarPanel(
      sliderInput("opacity", "Opacity (not for Sankey)", 0.6, min = 0.1,
                  max = 1, step = .1)
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Simple Network", simpleNetworkOutput("simple")),
        tabPanel("Force Network", forceNetworkOutput("force"))
      )
    )
  )
))
shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
    ),
    fluidRow(id = "maindiv", 
      column(3, id = "inputscontainer",
             h1("inputs"),
             numericInput("zoom", "Zoom", min = 0, max = 500, value = 17)
             ),
      column(9, id = "mapcontainer",
             leafletOutput("map", width = "100%", height = "100%")
             )
      )
    )
  )
    
    
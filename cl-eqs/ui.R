shinyUI(
  fluidPage(id="main",
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/bootstrap.cosmo.min.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
    ),
    leafletOutput("map", width = "100%", height = "100%")
    )
  )
dashboardPage(skin = "black",
  dashboardHeader(),
  dashboardSidebar(
    textInput("text", "text", "text"),
    sliderInput("slider", "slider", 0, 10, 2)
  ),
  dashboardBody(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
      ),
    leafletOutput("map", width = "100%", height = "100%")
    )
  )
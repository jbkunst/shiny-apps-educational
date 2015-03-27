shinyUI(
  fluidPage(
    includeCSS(file.path("www", "css", "bootstrap.cosmo.min.css")),
    fluidRow(
        column(width = 12, "Hola")
        ),
    fluidRow(
      column(width = 3,
             h4("SideBar"),
             sliderInput("range_price", "Custom Format:",  min = 0, max = 1e6, value = c(0, 1e6), pre="$")
             ),
      column(width = 9, "ContentBar")
      )
    )
  )

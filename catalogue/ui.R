shinyUI(
  fluidPage(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/bootstrap.cosmo.min.css"),
    fluidRow(
      column(width = 3,
             h4("SideBar"),
             
             radioButtons("category", "Categoría", choices = unique(data$category)),
             
             sliderInput("range_price", "Precio",  min = 0, max = 1e9, value = c(0, 1e9), pre="$")
             
             ),
      column(width = 9,
             h4("ContentBar"),
             
             dataTableOutput("products")
             
             )
      )
    )
  )
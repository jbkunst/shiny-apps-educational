shinyUI(
  fluidPage(id="main",
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/bootstrap.cosmo.min.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
    ),
    leafletOutput("map", width = "100%", height = "100%"),
    
    absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                  h3("Últimos sismos en Chile"),
                  h4("Con magnitud igual o superior a 3.0"),
                  hr(),
                  p("Fuente de información ",
                    a(href="http://www.sismologia.cl/", "aquí", target="_blank")
                    ),
                  checkboxInput(inputId = "showtable",
                                label = "Motrar datos",
                                value = FALSE),
                  conditionalPanel(condition = "input.showtable == true",
                                   checkboxInput(inputId = "showmoretable",
                                                 label = "Detalles",
                                                 value = FALSE),
                                   dataTableOutput("table")
                                   )
                  )
    )
  )
shinyUI(
  fluidPage(id="main",
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/bootstrap.cosmo.min.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
      tags$script(src="js/script.js")
    ),
    leafletOutput("map", width = "100%", height = "100%"),
    
    absolutePanel(id = "controls", class = "panel panel-default", fixed = TRUE, draggable = TRUE,
                  h3("Últimos sismos en Chile"),
                  h4("Con magnitud igual o superior a 3.0"),
                  hr(),
                  checkboxInput(inputId = "filterdata",
                                label = "Filtrar datos",
                                value = FALSE),
                  conditionalPanel(condition = "input.filterdata == true",
                                   sliderInput("fmagnitud", "Magnitud (Ml)",
                                               min = 0, max = max(data$Magnitud), value = c(0, max(data$Magnitud)), ticks=FALSE),
                                   sliderInput("fproundidad", "Proundidad (KM)",
                                               min = 0, max = max(data$Profundidad), value = c(0, max(data$Profundidad)), ticks=FALSE)
                  ),
                  checkboxInput(inputId = "showdata",
                                label = "Motrar datos",
                                value = FALSE),
                  conditionalPanel(condition = "input.showdata == true",
                                   dataTableOutput("table")
                                   ),
                  p("Fuente de información ",
                    a(href="http://www.sismologia.cl/", "aquí", target="_blank")
                    )
                  )
    )
  )
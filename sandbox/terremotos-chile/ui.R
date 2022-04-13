shinyUI(
  fluidPage(id = "main",
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/bootstrap.cosmo.min.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
      tags$script(src = "js/script.js")
    ),
    leafletOutput("map", width = "100%", height = "100%"),
    
    absolutePanel(id = "controls", class = "panel panel-default small", fixed = FALSE, draggable = TRUE,
                  h4("Últimos sismos en Chile"),
                  h5("Con magnitud igual o superior a 3.0"),
                  hr(),
                  checkboxInput(inputId = "showpanel",
                                label = "Mostrar Panel Control",
                                value = FALSE),
                  conditionalPanel(condition = "input.showpanel == true",
                                   sliderInput("fmagnitud", "Magnitud (Ml)",
                                               min = 0, max = 1000, value = c(0, 1000), ticks = FALSE),
                                   sliderInput("fproundidad", "Proundidad (KM)",
                                               min = 0, max = 1000, value = c(0, 1000), ticks = FALSE),
                                   checkboxInput(inputId = "showdata",
                                                 label = "Mostrar Datos",
                                                 value = FALSE),
                                   conditionalPanel(condition = "input.showdata == true",
                                                    DT::dataTableOutput("table")
                                                    )
                                   ),
                  p(class = "pull-right",
                    "Datos por",
                    a(href = "http://www.sismologia.cl/", "Sismologia.cl", target = "_blank"),
                    " | Codeado por ",
                    a(href = "http://jkunst.com", "Joshua Kunst", target = "_blank"),
                    " | Repo acá ",
                    a(href = "https://github.com/jbkunst/shiny-apps/tree/master/cl-eqs", icon("github"), target = "_blank")
                  )
                  )
    )
  )
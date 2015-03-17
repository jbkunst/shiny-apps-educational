shinyUI(
  fluidPage(id="main",
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/bootstrap.cosmo.min.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
      tags$script(src="js/script.js")
    ),
    leafletOutput("map", width = "100%", height = "100%"),
    
    absolutePanel(id = "controls", class = "panel panel-default small", fixed = TRUE, draggable = TRUE,
                  h4("The Latest Earthquakes Worldwide"),
                  h5("Magnitude > 4"),
                  hr(),
                  checkboxInput(inputId = "showpanel",
                                label = "Show control panel",
                                value = FALSE),
                  conditionalPanel(condition = "input.showpanel == true",
                                   sliderInput("fmag", "Magnitude",
                                               min = 0, max = 1000, value = c(5,6), ticks=FALSE),
                                   sliderInput("fdepth", "Depth",
                                               min = 0, max = 1000, value = c(0, 1000), ticks=FALSE),
                                   checkboxInput(inputId = "showdata",
                                                 label = "Show data",
                                                 value = FALSE),
                                   conditionalPanel(condition = "input.showdata == true",
                                                    dataTableOutput("table")
                                                    )
                                   ),
                  hr(),
                  p(class="pull-right",
                    "Information by", a(href="http://ds.iris.edu/seismon/eventlist/index.phtml", "IRIS", target="_blank"),
                    " | ",
                    "Code by ", a(href="http://jkunst.com", "Joshua Kunst", target="_blank"),
                    " | ",
                    "Code here ", a(href="https://github.com/jbkunst/shiny-apps/tree/master/ww-eqs", icon("github"), target="_blank")
                    )
                  )
  )
)
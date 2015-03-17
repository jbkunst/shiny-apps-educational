shinyUI(
  fluidPage(id="main",
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/bootstrap.cosmo.min.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
      tags$script(src="js/script.js")
    ),
    leafletOutput("map", width = "100%", height = "100%"),
    
    absolutePanel(id = "controls", class = "panel panel-default small", fixed = TRUE, draggable = TRUE,
                  h4("The Latest Earthquakes"),
                  h5("World Wide"),
                  hr(),
                  checkboxInput(inputId = "showpanel",
                                label = "Show control panel",
                                value = FALSE),
                  conditionalPanel(condition = "input.showpanel == true",
                                   selectizeInput("fregion", "Region", choices_region, multiple  = FALSE),
                                   sliderInput("fmag", "Magnitud (Ml)",
                                               min = 0, max = mag_max, value = c(0, mag_max), ticks=FALSE),
                                   sliderInput("fdepth", "Proundidad (KM)",
                                               min = 0, max = depth_max, value = c(0, depth_max), ticks=FALSE),
                                   checkboxInput(inputId = "showdata",
                                                 label = "Show data",
                                                 value = FALSE),
                                   conditionalPanel(condition = "input.showdata == true",
                                                    dataTableOutput("table")
                                                    )
                                   ),
                  hr(),
                  p(class="pull-right",
                    "Information by", a(href="http://ds.iris.edu/ds/", "IRIS", target="_blank"), " | ",
                    "Code by ", a(href="http://jkunst.com", "Joshua Kunst", target="_blank"), " | ",
                    "Code here ", a(href="https://github.com/jbkunst/shiny-apps/tree/master/ww-eqs", icon("github"))
                    )
                  )
  )
)
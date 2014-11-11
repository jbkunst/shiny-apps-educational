shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
      ),
    fluidRow(
      column(width = 12, id = "menu",
             h2(id="title", "Pone Título Aquí"),
             br(),
             tabsetPanel(type = "pills", selected = "ACERCA DE",
               tabPanel("PAÍS",
                        p("en construcción")
                        ),
               tabPanel("REGIÓN",
                        selectizeInput("region_numero", NULL, regiones_choices, width = "400"),
                        p("en construcción")
                        ),
               tabPanel("COLEGIO",
                        column(width = 3,
                               selectizeInput("colegio_rbd", NULL, colegios_choices, selected = 10726, width="90%"),
                               selectizeInput("indicador", NULL, indicador_choices, width="90%"),
                               hr(),
                               tags$span(paste(
                                 "Puedes comparar el colegio seleccionado",
                                 "considerando los colegios con características similares:"
                               )),
                               br(),
                               checkboxInput("colegio_misma_region", "Misma region", FALSE),
                               checkboxInput("colegio_misma_dependencia", "Misma dependencia", FALSE),
                               checkboxInput("colegio_misma_area", "Misma área geográfica", FALSE),
                               br()
                               ),
                        column(width = 5,
                               includeScript("www/js/hc_custom.js"), 
                               chartOutput("plot_colegio", "highcharts"),
                               br()
                               ),
                        column(width = 4,
                               uiOutput("report_colegio")
                        )
                        ),
               tabPanel("ACERCA DE",
                        column(width = 6,
                               includeMarkdown("report/acerca.md")
                               )
                        )
               )
             )
      )
    )
  )
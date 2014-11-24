shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
      includeScript("www/js/hc_custom.js")
      ),
    fluidRow(
      column(width = 12, id = "menu",
             h2(id="title", "Pone Título Aqui"),
             br(),
             tabsetPanel(type = "pills", selected = "REGION",
               tabPanel("PAIS",
                        p("en construccion")
                        ),
               tabPanel("REGION",
                        column(width = 4,
                               selectizeInput("region_numero", NULL, regiones_choices, width = "400")
                               ),
                        column(width = 5,
                               selectizeInput("region_indicador", NULL, region_indicador_choices, width="90%"),
                               plotOutput("map_reg"),
                               div(class="space")
                        ),
                        column(width = 3,
                               plotOutput("map_chi_reg", height = "600px")
                               )
                        ),
               tabPanel("COLEGIO",
                        column(width = 4,
                               selectizeInput("colegio_rbd", NULL, colegios_choices, selected = 10726, width="90%"),
                               selectizeInput("indicador", NULL, indicador_choices, width="90%"),
                               div(class="space"),
                               tags$span(paste(
                                 "Puedes comparar el colegio seleccionado",
                                 "considerando los colegios con caracteristicas similares:"
                               )),
                               div(class="space"),
                               checkboxInput("colegio_misma_region", "misma region", FALSE),
                               checkboxInput("colegio_misma_dependencia", "misma dependencia", FALSE),
                               checkboxInput("colegio_misma_area", "misma area geografica", FALSE),
                               div(class="space")
                               ),
                        column(width = 5,
                               chartOutput("plot_colegio", "highcharts"),
                               br()
                               ),
                        column(width = 3,
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
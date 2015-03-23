shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
      ),
    fluidRow(
      includeScript("www/js/hc_custom.js"),
      h2(id="title", "Indicadores de Educación en Chile"),
      div(class="space"),
      tabsetPanel(type = "pills", selected = "PAIS",
                  tabPanel("PAIS",
                           column(width = 9,
                                  uiOutput("report_pais")
                                  ),
                           column(width = 3,
                                  plotOutput("map_chi_reg_main", height = "580px"),
                                  div(class="space")
                                  )
                           ),
                  tabPanel("REGION",
                           column(width = 4,
                                  selectizeInput("region_numero", NULL, regiones_choices, width = "90%"),
                                  selectizeInput("region_indicador", NULL, region_indicador_choices, width="90%"),
                                  div(class="space"),
                                  chartOutput("plot_region", "highcharts")
                                  ),
                           column(width = 5,
                                  uiOutput("report_region"),
                                  div(class="space"),
                                  plotOutput("map_reg", height = "350px"),
                                  fluidRow(
                                    column(width = 6, sliderInput("region_map_size", "Tamanio", 1, 10, 3)),
                                    column(width = 6, sliderInput("region_map_alpha", "Transparencia", 0, 1, 0.3))
                                    )
                                  ),
                           column(width = 3,
                                  plotOutput("map_chi_reg", height = "580px"),
                                  div(class="space")
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
                                  div(class="space")
                                  ),
                           column(width = 3,
                                  uiOutput("report_colegio")
                                  )
                           ),
                  tabPanel("ACERCA DE",
                           column(width = 6,
                                  includeMarkdown("report/acerca.md")
                                  ),
                           column(width = 6,
                                  div(class="space"),
                                  tags$img(src="img/escolares.jpg", width = "100%")
                                  )
                           )
                  )
      )
    )
  )
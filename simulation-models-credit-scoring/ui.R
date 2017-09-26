shinyUI(
  fluidPage(theme =  shinytheme("flatly"),
    h2(class = "text-center", "Simulación de Escenarios"),
    fluidRow(
      column(3, sliderInput("n", "Solicitudes", value = 5000, min = 500, max = 10000, ticks = FALSE, width = "100%")),
      column(3, sliderInput("m", "Monto Promedio", value = 3e6, min = 1e6, max = 15e6, ticks = FALSE, pre = "$", width = "100%")),
      column(3, sliderInput("br", "BadRate", value = 10, min = 0, max = 100, ticks = FALSE, post = "%", width = "100%")),
      column(3, sliderInput("dec", "Regla Decisión", value = 15, min = 0, max = 100, ticks = FALSE, post = "%", width = "100%"))
    ),
    fluidRow(
      column(5, offset = 0,
             sliderInput("m1", NULL, min = 0, max = 1000, value = c(450, 550), width = "100%"),
             highchartOutput("d1", height = 150),
             formattableOutput("ind1"),
             formattableOutput("m1")
             ),
      column(5, offset = 2,
             sliderInput("m2", NULL, min = 0, max = 1000, value = c(250, 750), width = "100%"),
             highchartOutput("d2", height = 150),
             formattableOutput("ind2"),
             formattableOutput("m2")
             ),
      column(6, formattableOutput("bench")),
      column(6, formattableOutput("bench2"))
      )
    )
  )

# packages ----------------------------------------------------------------
library(shiny)
library(bslib)
library(plotly)
library(ggplot2)
library(dplyr)

# theme options -----------------------------------------------------------
apptheme <- bs_theme()

sidebar <- purrr::partial(bslib::sidebar, width = 300)

card <- purrr::partial(bslib::card, full_screen = TRUE)

thematic::thematic_shiny(font = "auto")

theme_set(theme_minimal() + theme(legend.position = "none"))

# app options -------------------------------------------------------------
generate_lorenz <- function(sigma = 10, rho = 28, beta = 8/3, 
                            start = c(1, 1, 1), n = 1000, dt = 0.01) {
  x <- y <- z <- numeric(n)
  x[1] <- start[1]
  y[1] <- start[2]
  z[1] <- start[3]
  
  for (i in 2:n) {
    dx <- sigma * (y[i-1] - x[i-1])
    dy <- x[i-1] * (rho - z[i-1]) - y[i-1]
    dz <- x[i-1] * y[i-1] - beta * z[i-1]
    
    x[i] <- x[i-1] + dx * dt
    y[i] <- y[i-1] + dy * dt
    z[i] <- z[i-1] + dz * dt
  }
  
  data.frame(x = x, y = y, z = z, time = 1:n)
}

# ui ---------------------------------------------------------------------
ui <- page_fillable(
  theme = apptheme,
  padding = 0,
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      title = "Lorenz System Parameters",
      withMathJax(),
      sliderInput("sigma", "\\( \\sigma \\) (sigma):", 
                  min = 1, max = 20, value = 10, step = 0.1),
      sliderInput("rho", "\\( \\rho \\) (rho):", 
                  min = 1, max = 50, value = 28, step = 0.1),
      sliderInput("beta", "\\( \\beta \\) (beta):", 
                  min = 0.1, max = 10, value = 8/3, step = 0.1),
      numericInput("n_points", "Number of points:", 
                   value = 1000, min = 100, max = 5000),
      numericInput("dt", "Time step (dt):", 
                   value = 0.01, min = 0.001, max = 0.1, step = 0.001),
      tags$small(htmltools::includeMarkdown("readme.md"))
    ),
    layout_columns(
      col_widths = c(12, 4, 4, 4),
      row_heights = c(3, 2),
      card(
        card_header("3D Lorenz Attractor"),
        plotlyOutput("lorenz3d", height = "100%")
      ),
      card(
        card_header("X-Y Projection"),
        plotOutput("xy_plot")
      ),
      card(
        card_header("X-Z Projection"),
        plotOutput("xz_plot")
      ),
      card(
        card_header("Y-Z Projection"),
        plotOutput("yz_plot")
      )
    )
  )
)

# server -----------------------------------------------------------------
server <- function(input, output, session) {
  
  lorenz_data <- reactive({
    generate_lorenz(
      sigma = input$sigma,
      rho = input$rho,
      beta = input$beta,
      n = input$n_points,
      dt = input$dt
    )
  })
  
  output$lorenz3d <- renderPlotly({
    df <- lorenz_data()
    
    plot_ly(df, x = ~x, y = ~y, z = ~z, type = 'scatter3d', mode = 'lines',
            line = list(width = 2, color = ~time, colorscale = 'Viridis')) %>%
      layout(scene = list(
        xaxis = list(title = "X"),
        yaxis = list(title = "Y"),
        zaxis = list(title = "Z")
      ))
  })
  
  output$xy_plot <- renderPlot({
    df <- lorenz_data()
    ggplot(df, aes(x = x, y = y, color = time)) +
      geom_path() +
      scale_color_viridis_c() +
      labs(title = "X-Y Projection")
  })
  
  output$xz_plot <- renderPlot({
    df <- lorenz_data()
    ggplot(df, aes(x = x, y = z, color = time)) +
      geom_path() +
      scale_color_viridis_c() +
      labs(title = "X-Z Projection")
  })
  
  output$yz_plot <- renderPlot({
    df <- lorenz_data()
    ggplot(df, aes(x = y, y = z, color = time)) +
      geom_path() +
      scale_color_viridis_c() +
      labs(title = "Y-Z Projection") 
  })
}

shinyApp(ui, server)

# packages ----------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(highcharter)
library(markdown)

# parameters & options ----------------------------------------------------
primary_color <- "#262162"
colors_app    <- c(primary_color, hc_theme_smpl()$colors[c(1, 4)])
# scales::show_col(hc_theme_smpl()$color)

apptheme <- bs_theme(
  bg = "#F5F5F5",
  fg = "#36454F", 
  primary = primary_color, 
  base_font =  font_google("IBM Plex Sans")
  )

sidebar <- purrr::partial(
  sidebar, 
  bg = "#FDFDFD",
  fg = "#36454F",
  width = 300
  )

card <- function(...) bslib::card(..., style = "background-color: #FDFDFD;")

LAG_MAX  <- 10
STR_OBS  <- 20
NOBS     <- 5000
AR       <- 0.0
MA       <- 0.20
SEED     <- 123
DURATION <- 100 # needs to be <= than min refresh interval

options(highcharter.theme = hc_theme_hcrt(colors = colors_app))

# start chart
set.seed(SEED)

ts_aux <- arima.sim(model = list(ar = AR, ma = MA), n = STR_OBS)

teoACF <- as.numeric(ARMAacf(ar = AR, ma = MA, lag.max = LAG_MAX, pacf = FALSE))
smpACF <- as.numeric(acf(ts_aux, lag.max = LAG_MAX, plot = TRUE)$acf)

plot(smpACF, ylim = c(-1, 1))
lines(teoACF)

teoPACF <- as.numeric(ARMAacf(ar = AR, ma = MA, lag.max = LAG_MAX, pacf = TRUE))
smpPACF <- as.numeric(pacf(ts_aux, lag.max = LAG_MAX, plot = TRUE)$acf)

plot(smpPACF, ylim = c(-1, 1))
lines(teoPACF)

# ui ----------------------------------------------------------------------
ui <- page_fillable(
  theme = apptheme,
  padding = 0,
  layout_sidebar(
    fillable = TRUE,
    border = FALSE,
    sidebar = sidebar(
      title = "ARMA model Simulation",
      sliderInput("ar", "AR", -.9, .9, value = AR, 0.05, width = "100%"),
      sliderInput("ma", "MA", -.9, .9, value = MA, 0.05, width = "100%"),
      sliderInput("interval", "Refresh (secs.)", 0.5, 2, value = 1, step = 0.5, width = "100%"),
      tags$small(htmltools::includeMarkdown("readme.md"))
      ),
    layout_column_wrap(
      width = 1/1,
      card(card_header(uiOutput("model", inline = TRUE)), card_body(highchartOutput("ts")))
      ),
    br(),
    layout_column_wrap(
      width = 1/2,
      card(card_header("ACF"), card_body(highchartOutput("acf"))), 
      card(card_header("PACF"), card_body(highchartOutput("pacf")))
      )
    )
  )

# server ------------------------------------------------------------------
server <- function(input, output, session) {
  
  # input <- list(ar = AR, ma = MA); input
  
  value <- reactiveVal(STR_OBS)
  
  ts <- reactive({
    
    value(STR_OBS)
    
    # input <- list(ar = 0.9, ma = 0.1, nobs = 200)
    set.seed(SEED)
    
    ts <- arima.sim(model = list(ar = input$ar, ma = input$ma), n = NOBS)
    
  })
  
  output$model <- renderUI({
    
    arp <- ifelse(input$ar != 0, paste0(input$ar, " \\times X_{t-1}"), "")
    map <- ifelse(input$ma != 0, paste0(" + ", input$ma, " \\times \\epsilon_{t-1}"), "")
    
    mod <- paste0("X_{t} = ",
                  arp,
                  ifelse(input$ar != 0, " + ", ""),
                  "\\epsilon_t",
                  map
    )
    
    mod <- paste0("$$", mod, "$$")
    
    tags$small(tags$p(withMathJax(mod)))
    
  })
  
  output$ts <- renderHighchart({
    
    ts <- ts()
    
    df <- data.frame(x = 1:STR_OBS, y = head(ts, STR_OBS))
    
    hchart(
      df,
      "line",
      id = "ts",
      name = "Time series",
      marker = list(enabled = FALSE),
      animation = list(duration = DURATION),
      tooltip = list(valueDecimals = 3)
    ) %>%
      hc_navigator(
        enabled = TRUE,
        series = list(type = "line"),
        xAxis = list(labels = list(enabled = FALSE))
      ) %>%
      hc_yAxis_multiples(
        # default axis
        list(title = list(text = "")),
        list(
          title = list(text = ""),
          linkedTo = 0,
          opposite = TRUE,
          tickPositioner = JS(
            "function(min,max){
               var data = this.chart.yAxis[0].series[0].processedYData;
               //last point
               return [Math.round(1000 * data[data.length-1])/1000];
            }"
          )
        )
      )
    
  })
  
  observeEvent(ts(), {
    
    # if ts change redraw the teo ACF
    ts <- ts()
    
    # message("asdasda")
    
    print(input$ar)
    print(input$ma)
    
    teoACF <- as.numeric(
      ARMAacf(
        # ar = 0.2,
        # ma = 0.2,
        ar = ifelse(!is.null(input$ar), input$ar, AR),
        ma = ifelse(!is.null(input$ma), input$ar, MA),
        lag.max = LAG_MAX,
        pacf = FALSE
      )
    )
    
    smpACF <- as.numeric(acf(head(ts, STR_OBS), lag.max = LAG_MAX, plot = FALSE)$acf)
    
    highchartProxy("acf") %>%
      hcpxy_update_series(id = "tacf", data = teoACF) %>%
      hcpxy_update_series(id = "sacf", data = smpACF)
    
    teoPACF <- as.numeric(
      ARMAacf(
        # ar = 0.2,
        # ma = 0.2,
        ar = ifelse(!is.null(input$ar), input$ar, AR),
        ma = ifelse(!is.null(input$ma), input$ar, MA),
        lag.max = LAG_MAX,
        pacf = TRUE
      )
    )
    
    smpPACF <- as.numeric(pacf(head(ts, STR_OBS), lag.max = LAG_MAX, plot = FALSE)$acf)
    
    highchartProxy("pacf") %>%
      hcpxy_update_series(id = "tpacf", data = teoPACF) %>%
      hcpxy_update_series(id = "spacf", data = smpPACF)
    
  })
  
  observe({
    
    interval <- max(as.numeric(input$interval), 0.25)
    
    invalidateLater(1000 * interval, session)
    
    # animation <- ifelse(interval < 0.5, FALSE, TRUE)
    animation <- TRUE
    
    value_to_add <- isolate(value()) + 1
    # value_to_add <- 11
    value(value_to_add)
    
    ts <- ts()
    
    smpACF <- as.numeric(acf(head(ts, value_to_add), lag.max = LAG_MAX, plot = FALSE)$acf)
    
    highchartProxy("acf") %>%
      hcpxy_update_series(id = "sacf", data = smpACF)
    
    highchartProxy("ts") %>%
      hcpxy_add_point(
        id = "ts",
        point = list(x = value_to_add, y = ts[value_to_add]),
        animation = animation
      )
    
  })
  
  output$acf <- renderHighchart({
    
    highchart() |>
      hc_chart(type = "column") |>
      hc_yAxis(min = -1, max = 1) |>
      hc_add_series(
        data = smpACF,
        id = "sacf",
        name = "Estimated"
      ) |>
      hc_add_series(
        data = teoACF, 
        id = "tacf",
        name = "Theoretical"
      ) |>
      hc_tooltip(
        table = TRUE,
        headerFormat = "<small>Lag {point.key}</small><table>",
        valueDecimals = 3
      ) |>
      hc_plotOptions(
        series = list(
          pointWidth = 5,
          animation = list(duration = DURATION),
          marker = list(symbol = "circle")
        )
      )
    
  })
  
  output$pacf <- renderHighchart({
    
    highchart() |>
      hc_chart(type = "column") |>
      hc_yAxis(min = -1, max = 1) |>
      hc_add_series(
        data = smpPACF,
        id = "spacf",
        name = "Estimated"
      ) |>
      hc_add_series(
        data = teoPACF, 
        id = "tpacf",
        name = "Theoretical"
      ) |>
      hc_tooltip(
        table = TRUE,
        headerFormat = "<small>Lag {point.key}</small><table>",
        valueDecimals = 3
      ) |>
      hc_plotOptions(
        series = list(
          pointStart = 1,
          pointWidth = 5,
          animation = list(duration = DURATION),
          marker = list(symbol = "circle")
        )
      )
  })
  
}

shinyApp(ui, server)

# packages ----------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(highcharter)
library(markdown)

# theme options -----------------------------------------------------------
apptheme <- bs_theme()

sidebar <- purrr::partial(bslib::sidebar, width = 300)

card <- purrr::partial(bslib::card, full_screen = TRUE)

options(
  highcharter.theme = hc_theme(
    chart = list(style = list(fontFamily =  "system-ui")),
    colors = unname(bs_get_variables(apptheme, c("primary", "danger", "warning", "success", "info", "secondary"))),
    tooltip = list(valueDecimals = 3, shared = TRUE),
    plotOptions = list(
      spline = list(marker = list(enabled = FALSE, symbol = "cirlce")),
      line = list(marker = list(enabled = FALSE, symbol = "cirlce")),
      scatter = list(
        marker = list(symbol = "cirlce"),
        animation = list(duration = 100),
        events = list(legendItemClick = JS("function () { return false; }"))
      )
    ),
    legend = list(
      # this for legendItemClick false
      itemStyle = list(cursor = "default"),
      # itemStyle = list(color = "#666666"),
      itemHiddenStyle = list(color = "#666666")
      # itemHoverStyle = list(color = "#666666")
    )
  )
)

# app options -------------------------------------------------------------
metric <- Metrics::rmse

ker <- function (u, kerntype = c("Gaussian", "Epanechnikov", "Quartic", 
                                 "Triweight", "Triangular", "Uniform")) {
  kerntype = match.arg(kerntype)
  if (kerntype == "Gaussian") {
    result = 1/(sqrt(2 * pi)) * exp(-0.5 * (u^2))
  }
  else {
    lenu = length(u)
    result = vector(, lenu)
    for (j in 1:lenu) {
      if (abs(u[j]) <= 1) {
        if (kerntype == "Epanechnikov") {
          result[j] = 3/4 * (1 - u[j]^2)
        }
        if (kerntype == "Quartic") {
          result[j] = 15/16 * ((1 - u[j]^2)^2)
        }
        if (kerntype == "Triweight") {
          result[j] = 35/32 * ((1 - u[j]^2)^3)
        }
        if (kerntype == "Triangular") {
          result[j] = (1 - abs(u[j]))
        }
        if (kerntype == "Uniform") {
          result[j] = 1/2
        }
      }
      else {
        result[j] = 0
      }
    }
  }
  return(result)
}

NadarayaWatsonkernel <- function (x, y, h, gridpoint){
  
  n = length(y)
  mh = vector(, length(gridpoint))
  for (j in 1:length(gridpoint)) {
    suma = sumb = vector(, n)
    for (i in 1:n) {
      suma[i] = ker((gridpoint[j] - x[i]) / h) * y[i]
      sumb[i] = ker((gridpoint[j] - x[i]) / h)
    }
    mh[j] = sum(suma) / sum(sumb)
  }
  
  return(list(gridpoint = gridpoint, mh = mh))
}



# ui ----------------------------------------------------------------------
ui <- page_fillable(
  theme = apptheme,
  padding = 0,
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      title = "Bias & Variance",
      sliderInput(
        "bandwidth",
        tags$small("Model's bandwidth"),
        min = 0.1,
        max = 20,
        step = 1,
        value = 10
      ),
      sliderInput(
        "n",
        tags$small("Number of train observations"),
        min = 50,
        max = 100,
        step = 10,
        value = 50
      ),
      shiny::checkboxInput(
        "show_train",
        tags$small("Show train set information"),
        value = FALSE
      ),
      tags$small(htmltools::includeMarkdown("readme.md"))
    ),
    
    layout_columns(
      col_widths = c(12, 6, 6),
      row_heights = c(3, 2),
      card(card_body(highchartOutput("chartdata"))),
      card(card_body(highchartOutput("charterror"))), 
      card(card_body(highchartOutput("chartbandwidth")))
      )
    )
  )

# server ------------------------------------------------------------------
server <- function(input, output, session) {
  
  # input <- list(n = 100, bandwidth = 10)
  
  dxy <- reactive({
    
    set.seed(1234)
    
    s <- seq(1:input$n)/input$n 
    d <- max(diff(s))
    
    # dxy <- tibble(x = c(s, s) + runif(2*input$n, -d/2 + d/2)) |> 
    dxy <- tibble(x = c(s, s) + 0) |>     
      mutate(
        x = scales::rescale(x, to = c(0, 100)),
        # e = rnorm(input$n * 2, sd = 10),
        y = x + 10 * sin(x / 5) + 20 * sin(x / 20) ,
        y = y + rnorm(input$n * 2, sd = 10),
        s = ifelse(1:(2*input$n) <= input$n, "test", "train")
      )
    
    # ggplot(dxy, aes(x, y, color = s)) +
    #   geom_point() +
    #   geom_smooth(span = 0.1)
    
    dxy
    
  })
  
  dpred <- reactive({
    
    dxy <- dxy()
    
    dxy_test <- dxy |>
      filter(s == "train")
    
    nwk <- NadarayaWatsonkernel(
      dxy_test$x, 
      dxy_test$y,
      h = input$bandwidth,
      gridpoint = dxy_test$x
      # gridpoint = seq(0, 100, length.out = 100)
    )
    
    dpred <- tibble(x = nwk$gridpoint, y = nwk$mh)
    
    # ksmooth
    # ksm <- ksmooth(dxy$x, dxy$y, "normal", bandwidth = input$span, n.points = 1000)
    # 
    # dpred <- tibble(x = ksm$x, y = ksm$y)
    
    # loess
    # dpred <- dxy |> 
    #   filter(s == "train") |> 
    #   select(-s)
    # 
    # dpred <- dpred |>
    #   mutate(y = predict(loess_mod, newdata = dpred)) |> 
    #   arrange(x)
    
    dpred
    
  })
  
  derr <- reactive({
    
    dpred <- dpred()
    dxy   <- dxy()
    
    derr <- dxy |>
      left_join(dpred, by = "x", suffix = c("_real", "_model")) |>
      group_by(s) |>
      summarise(error = metric(y_real, y_model))
    
    derr
    
  })
  
  # this is a generalization of dpred() and derr()
  derr_bw <- reactive({
    
    dxy   <- dxy()
    
    dxy_test <- dxy |>
      filter(s == "train")
    
    # this can have the same step that input$bandwidth
    sq <- c(0.1, seq(from = 1, to = 20, by = 1))
    
    derr_bw <- map_df(sq, function(bw = 10){
      
      nwk <- NadarayaWatsonkernel(
        dxy_test$x, 
        dxy_test$y,
        h = bw,
        gridpoint = dxy_test$x
      )
      
      dpred <- tibble(x = nwk$gridpoint, y = nwk$mh)
      
      derr <- dxy |>
        left_join(dpred, by = "x", suffix = c("_real", "_model")) |>
        group_by(s) |>
        summarise(error = metric(y_real, y_model))
      
      derr |> 
        mutate(bw = bw)
      
    })
    
    # ggplot(derr_bw) +
    #   geom_line(aes(bw, error, group = s, color = s))
    
    derr_bw
    
  })
  
  output$chartdata <- renderHighchart({
    
    # isolate, so works only one time 
    dpred <- isolate(dpred())
    dxy   <- isolate(dxy())
    
    dxyg <- dxy |> 
      group_nest(s) |> 
      deframe()
    
    highchart() |> 
      hc_chart(type = "scatter") |> 
      
      hc_xAxis(title = list(text = "Variable X")) |>
      hc_yAxis(title = list(text = "Variable Y")) |> 
      
      hc_add_series(
        data = list_parse2(dpred),
        id = "model",
        name = "Model",
        type = "line",
        zIndex = 3
      ) |> 
      hc_add_series(
        data = list_parse2(dxyg$train), 
        id = "train",
        name = "Train set",
        zIndex = 2
      ) |> 
      hc_add_series(
        data = list_parse2(dxyg$test),
        id = "test",
        name = "Test set",
        visible = FALSE,
        showInLegend = FALSE,
        zIndex = 1
      )
    
  })
  
  observeEvent(c(input$n, input$bandwidth), {
    
    dpred <- dpred()
    dxy   <- dxy()
    
    dxyg <- dxy |> 
      group_nest(s) |> 
      deframe()
    
    highchartProxy("chartdata") |>
      hcpxy_update_series(id = "train", data = list_parse2(dxyg$train)) |> 
      hcpxy_update_series(id = "test", data = list_parse2(dxyg$test)) |> 
      hcpxy_update_series(id = "model", data = list_parse2(dpred))
    
  })
  
  output$charterror <- renderHighchart({
    
    # isolate, so works only one time
    derr <- isolate(derr())
    
    derrl <- as.list(deframe(derr))
    
    highchart() |>
      hc_chart(type = "column") |>
      hc_xAxis(title = list(text = "Dataset"), type = "category", categories = c("Train", "Test")) |>
      hc_yAxis(title = list(text = "Error"), max = 20) |> 
      hc_plotOptions(
        series = list(
          # showInLegend = FALSE,
          stacking = "normal",
          minPointLength = 0,
          dataLabels = list(
            enabled = TRUE,
            formatter = JS("function () { return Highcharts.numberFormat(this.y, 3); }")
          )
        )
      ) |>
      # this series just for mantain order colors
      hc_add_series(data = c(NA), showInLegend = FALSE) |>
      hc_add_series(data = tibble(x = 0, y = derrl$train), id = "train", name =  "Train") |>
      hc_add_series(data = tibble(x = 1, y = derrl$test), id = "test", name =  "Test", 
                    visible = FALSE, showInLegend = FALSE,) 
    
  })
  
  observeEvent(c(input$n, input$bandwidth), {
    
    derr <- derr()
    
    derrl <- as.list(deframe(derr))
    
    highchartProxy("charterror") |>
      hcpxy_update_series(id = "train", data = list_parse2(tibble(x = 0, y = derrl$train))) |>
      hcpxy_update_series(id = "test", data = list_parse2(tibble(x = 1, y = derrl$test)))
    
  })
  
  output$chartbandwidth <- renderHighchart({
    
    # isolate, so works only one time
    derr_bw <- isolate(derr_bw())
    bw      <- isolate(input$bandwidth)
    
    derr_bwg <- derr_bw |> 
      rename(x = bw, y = error) |> 
      dplyr::select(x, y, s) |> 
      group_nest(s) |> 
      deframe()
    
    highchart() |> 
      hc_chart(type = "line") |> 
      
      hc_xAxis(title = list(text = "Bandwidth")) |> 
      hc_yAxis(title = list(text = "Error"), max = 20) |> 
      
      hc_add_series(
        # type = "scatter",
        # tooltip = list(show = FALSE),
        enableMouseTracking = FALSE,
        data = list(
          list(x = bw, y = 0),
          list(x = bw, y = 20)
        ),
        showInLegend = TRUE,
        name = "Bandwidth",
        id = "bandwidth"
      ) |>
      
      hc_add_series(
        data = list_parse2(derr_bwg$train), 
        id = "train",
        name = "Train set",
        zIndex = 2
      ) |> 
      hc_add_series(
        data = list_parse2(derr_bwg$test),
        id = "test",
        name = "Test set",
        visible = FALSE,
        showInLegend = FALSE,
        zIndex = 1
      )
    
  })
  
  observeEvent(c(input$n, input$bandwidth), {
    
    derr_bw <- derr_bw()
    bw      <- input$bandwidth
    
    derr_bwg <- derr_bw |> 
      rename(x = bw, y = error) |> 
      dplyr::select(x, y, s) |> 
      group_nest(s) |> 
      deframe()
    
    highchartProxy("chartbandwidth") |>
      hcpxy_update_series(id = "bandwidth", data = list(list(x = bw, y = 0), list(x = bw, y = 20))) |>
      hcpxy_update_series(id = "train", data = list_parse2(derr_bwg$train)) |> 
      hcpxy_update_series(id = "test", data = list_parse2(derr_bwg$test))
    
  })
  
  observeEvent(input$show_train, {
    
    highchartProxy("chartdata") |>
      hcpxy_update_series(id = "test", visible = input$show_train, showInLegend = input$show_train)
    
    highchartProxy("charterror") |>
      hcpxy_update_series(id = "test", visible = input$show_train, showInLegend = input$show_train)
    
    highchartProxy("chartbandwidth") |>
      hcpxy_update_series(id = "test", visible = input$show_train, showInLegend = input$show_train)
    
  })
  
}

shinyApp(ui, server)
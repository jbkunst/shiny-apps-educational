# packages ----------------------------------------------------------------
library(shiny)
library(bslib)

library(dplyr)
library(stringr)
library(purrr)
library(tibble)

library(markdown)
library(highcharter)

# theme options -----------------------------------------------------------
primary_color <- "#262162"
# colors_app    <- c(primary_color, hc_theme_smpl()$colors[c(1, 4)])
# scales::show_col(hc_theme_smpl()$color)

# thematic::thematic_shiny(font = "auto")
# theme_set(theme_minimal() + theme(legend.position = "bottom"))

apptheme <- bs_theme(
  bg = "#F5F5F5",
  fg = "#36454F", 
  primary = primary_color, 
  base_font = font_google("IBM Plex Sans")
  )

sidebar <- purrr::partial(
  bslib::sidebar, 
  bg = "#FDFDFD",
  fg = "#36454F",
  width = 300
  )

card <- function(...) bslib::card(..., style = "background-color: #FDFDFD;", full_screen = TRUE)

# data --------------------------------------------------------------------
credit_data <- modeldata::credit_data |> 
  as_tibble() |> 
  rename_all(str_to_lower) |> 
  select(status, where(is.numeric)) |> 
  
  # avoid logscale problems
  filter(debt > 1) |> 
  
  # fewer points
  group_by(status) |>
  sample_n(200) |>

  ungroup()

# credit_data |> count(status)

# ui ----------------------------------------------------------------------
ui <- page_fillable(
  theme = apptheme,
  padding = 0,
  layout_sidebar(
    fillable = TRUE,
    border = FALSE,
    sidebar = sidebar(
      title = "Binary predicctions",
      withMathJax(),
      selectInput("variable", tags$small("Variable"), choices = names(credit_data)[-1]),
      checkboxInput("logscale", tags$small("Log-scale on \\(x\\)-axis")),
      tags$small(htmltools::includeMarkdown("readme.md"))
      ),
    layout_column_wrap(
      width = 1/2,
      height = "60%",
      card(highchartOutput("hcpoints"))
      ),
    br(),
    layout_column_wrap(
      width = 1/4,
      height = "40%",
      card(
        # card_header(uiOutput("iter")),
        # card_body(plotOutput("iter_plot"))
        )
      )
    )
  )



# server ------------------------------------------------------------------
server <- function(input, output, session) {
  
  # input <- list(variable = "time"); input

  data <- reactive({
    set.seed(123)
    data <- credit_data |> 
      select(status, variable = !!input$variable) |> 
      mutate(
        jitter = rbeta(n(), shape1 = 5, shape2 = 5),
        jitter = round(jitter, 3),
        id     = row_number()
        )
    data
  })
  
  output$hcpoints <- renderHighchart({
    
    varname <- isolate(input$variable)
    
    data <- isolate(data())
    datas <- data |> 
      ungroup() |> 
      group_nest(status) |> 
      mutate(data = map(data, select, x = variable, y = jitter, id)) |> 
      deframe() 

    highchart() |> 
      hc_yAxis(visible = FALSE) |> 
      hc_xAxis(title = list(text = varname)) |> 
      hc_add_series(name = "good", id = "good", data = datas[["good"]], type = "scatter") |> 
      hc_add_series(name = "bad", id = "bad",  data = datas[["bad"]], type = "scatter")
  })
  
  # update scatter/jitter
  observe({
    
    invalidateLater(1000)
    
    data <- data()

    datas <- data |>
      group_by(status) |> 
      group_nest() |>
      mutate(
        data = map(data, select, x = variable, y = jitter, id),
        data = map(data, list_parse)
        ) |>
      deframe()

    highchartProxy("hcpoints") |>
      hcpxy_update_series(id = "good", data = datas[["good"]]) |>
      hcpxy_update_series(id = "bad",  data = datas[["bad"]]) |> 
      hcpxy_update(
        xAxis = list(
          type = ifelse(input$logscale, "logarithmic", "linear"),
          title = list(text = str_to_title(input$variable))
          )
      )
    
  }) |> bindEvent(c(input$variable, input$logscale))
    
  
}

shinyApp(ui, server)

# packages ----------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(scales)
library(markdown)
library(broom)
library(metR)
library(scales)
library(patchwork)
library(geomtextpath) # remotes::install_github("AllanCameron/geomtextpath")
library(risk3r)       # remotes::install_github("jbkunst/risk3r", force = TRUE)
library(klassets)     # remotes::install_github("jbkunst/klassets", force = TRUE)
library(celavi)       # remotes::install_github("jbkunst/celavi", force = TRUE)

# theme options -----------------------------------------------------------
thematic::thematic_shiny(font = "auto")

theme_set(theme_minimal() + theme(legend.position = "bottom"))

apptheme <- bs_theme()

sidebar <- purrr::partial(bslib::sidebar, width = 300)

primary_color <- unname(bs_get_variables(apptheme, c("primary")))

# ui ----------------------------------------------------------------------
ui <- page_fillable(
  theme = apptheme,
  padding = 0,
  layout_sidebar(
    fillable = TRUE,
    border = FALSE,
    sidebar = sidebar(
      title = "Logistic Regression",
      withMathJax(),
      radioButtons(
        "relationship",
        tags$small("Relationship between \\(x\\), \\(y\\) and the response variable"),
        choices = list(
          "\\(x > y\\)" = "x > y",
          "\\(x^2 > y\\)" = "x^2 - y > 0",
          "\\(|x| > |y|\\)" = "abs(x) - abs(y) > 0",
          "\\(x^2 + y^2 < 0.5\\)" = "x^2 + y^2 < 0.5",
          "\\( \\sin(x \\cdot \\pi ) > \\sin(y \\cdot \\pi ) \\)" = "sin(x*pi) > sin(y*pi)"
          )
        ),
      sliderInput(
        "percent_noise",
        tags$small("Percent noise"),
        min = 0,
        max = 50,
        step = 5,
        value = 20,
        post = "%"
      ),
      sliderInput(
        "order",
        tags$span("Model Order"),
        min = 1,
        max = 4,
        step = 1,
        value = 1
      ),
      sliderInput(
        "n",
        tags$small("Number of observartions"),
        min = 100,
        max = 1000,
        step = 100,
        value = 1000
      ),
      checkboxInput(
        "apply_stepwise", 
        tags$small("Apply stepwise"),
        value = FALSE
      ),
      checkboxInput(
        "show_model_field", 
        tags$small("Show model predicctions"),
        value = TRUE
      ),
      tags$small(htmltools::includeMarkdown("readme.md"))
      ),
    layout_column_wrap(
      width = 1/2,
      height = "60%",
      card(card_body(plotOutput("join_dist", width = "100%", height = "100%")), full_screen = TRUE),
      card(card_body(plotOutput("marginal_dist", width = "100%", height = "100%")), full_screen = TRUE)
      ),
    layout_column_wrap(
      width = 1/3,
      height = "40%",
      card(card_body(plotOutput("roc_plot", width = "100%", height = "100%"))),
      card(card_body(plotOutput("bg_plot", width = "100%", height = "100%"))),
      card(card_body(tableOutput("coef_table")))
      )
    )
  )

# server ------------------------------------------------------------------
server <- function(input, output, session) {
  
  # input <- list(
  #   n = 500,
  #   relationship = "x > y",
  #   show_model_field = TRUE,
  #   show_xy_rel = TRUE,
  #   percent_noise = 10,
  #   order = 8,
  #   apply_stepwise = TRUE
  # ); input
  
  dxy <- reactive({
    
    dxy <- klassets::sim_response_xy(
      n = input$n,
      x_dist = purrr::partial(runif, min = -1, max = 1),
      relationship = function(x, y) eval(parse(text = input$relationship)),
      noise = input$percent_noise/100
    )
    
    dxy <- klassets::fit_logistic_regression(
      dxy, 
      order = input$order, 
      stepwise = input$apply_stepwise
    )
    
    dxy
    
  })
  
  output$join_dist <- renderPlot({
    
    dxy <- dxy()
    
    p <- ggplot()
    
    if(input$show_model_field) {
      
      p <- plot(dxy)
      
    } else {
      
      
      p <- klassets:::plot.klassets_response_xy(dxy)
      
    }
    
    p
    
  })
  
  output$marginal_dist <- renderPlot({
    
    dxy <- dxy()
    
    # dxy <- dxy |>
    #   mutate(pred = predict(mod, newdata = dxy, type = "response"))
    
    dg <- dxy |>
      select(x, y, response) |> 
      gather(key, value, -response) |>
      mutate(key = str_glue("variable {key}")) |> 
      mutate(response = as.logical(response))
    
    p <- ggplot() +
      # data
      geom_point(
        data = dg,
        aes(value, as.numeric(response), color = factor(response), shape = factor(response)),
        size = 3,
        alpha = 0.5,
        position = position_jitter(height = 0.05)
      ) +
      
      scale_shape_manual(name = NULL, values = c(1, 4)) +
      scale_color_manual(name = NULL, values = c(muted("blue"), muted("red"))) +
      
      scale_y_continuous(
        breaks = c(0, 1),
        labels = c("FALSE\n(response = 0)", "TRUE\n(response = 1)")
      ) +
      
      # predictions
      
      # geom_smooth(
      #   color = primary_color, size = 1.2, alpha = 0.1, 
      #   method = "loess", formula  = y ~ x
      #   ) +
      
      labs(
        x = NULL,
        y = NULL
      ) +
      
      facet_wrap(vars(key))
    
    if(input$show_model_field) {
      
      dg2 <- dxy |>
        select(x, y, prediction) |> 
        gather(key, value, -prediction) |>
        mutate(key = str_glue("variable {key}"))
      
      p <- p + 
        geom_smooth(
          data = dg2,
          aes(value, prediction),
          method = "loess",
          formula = y ~ x,
          color = primary_color
        )
      
    }
    
    p
    
  })
  
  output$roc_plot <- renderPlot({
    
    dxy <- dxy()
    
    droc <- risk3r::roc_data(
      actual = as.numeric(dxy$response),
      predicted = dxy$prediction
    )
    
    aucroc <- Metrics::auc(
      actual = as.numeric(dxy$response),
      predicted = dxy$prediction
    )
    
    ggplot(droc) +
      geom_line(aes(x, y), linewidth = 2, color = primary_color) +
      labs(title = str_glue("AUC: { percent(aucroc)  }")) +
      theme(legend.position = "none") +
      ggplot2::labs(x = "False positive rate (FPR)", 
                    y = "True positive rate (TPR)")
    
  })
  
  output$bg_plot <- renderPlot({
    
    dxy <- dxy()
    
    ksmod <- risk3r::ks(
      actual = as.numeric(dxy$response),
      predicted = 1 - dxy$prediction
    )
    
    ggplot(dxy, aes(1 - prediction, group = response, fill = response, color = response, label = response)) +
      geom_density(alpha = 0.1, linewidth = 2) +
      
      scale_color_manual(name = NULL, values = c(muted("red", 35), muted("blue", 35))) +
      
      geom_textdensity(size = 4, fontface = 1, hjust = 0.2, vjust = -0.5) +
      scale_y_continuous(labels = NULL) +
      scale_x_continuous(limits = c(0, 1)) + 
      labs(x = "Probability", y = "Density") +
      labs(title = str_glue("KS: { percent(ksmod) }")) +
      theme(legend.position = "none")
    
  })
  
  output$coef_table <- renderTable({
    
    dxy <- dxy()
    
    mod <- attr(dxy, "model")
    
    dmod <- tidy(mod) |> 
      mutate(
        term = str_replace_all(term, "_", "^"),
        ` ` = symnum(p.value, corr = FALSE, na = FALSE, legend = FALSE,
                     cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
                     symbols = c("***", "**", "*", ".", " "))
      )
    
    dmod
    
  })
  
}

shinyApp(ui, server)

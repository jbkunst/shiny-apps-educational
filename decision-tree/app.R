# packages ----------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(scales)
library(markdown)

library(geomtextpath) # remotes::install_github("AllanCameron/geomtextpath")
library(risk3r)       # remotes::install_github("jbkunst/risk3r", force = TRUE)
library(klassets)     # remotes::install_github("jbkunst/klassets", force = TRUE)
library(celavi)       # remotes::install_github("jbkunst/celavi", force = TRUE)

# parameters & options ----------------------------------------------------
primary_color <- "#262162"
# colors_app    <- c(primary_color, hc_theme_smpl()$colors[c(1, 4)])
# scales::show_col(hc_theme_smpl()$color)

thematic::thematic_shiny(font = "auto")
theme_set(theme_minimal() + theme(legend.position = "bottom"))

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

# ui ----------------------------------------------------------------------
ui <- page_fillable(
  theme = apptheme,
  padding = 0,
  layout_sidebar(
    fillable = TRUE,
    border = FALSE,
    sidebar = sidebar(
      title = "Decision Tree",
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
        "depth",
        tags$small("Maximum depth of the tree"),
        min = 1,
        max = 8,
        step = 1,
        value = 2
      ),
      sliderInput(
        "alpha",
        tags$small("Significance level for variable selection \\( \\alpha \\)"),
        min = 0,
        max = 1,
        step = 0.05,
        value = .1
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
      card(card_body(plotOutput("tree_plot", width = "100%", height = "100%")), full_screen = TRUE)
      ),
    br(),
    layout_column_wrap(
      width = 1/3,
      height = "40%",
      card(card_body(plotOutput("roc_plot", width = "100%", height = "100%"))),
      card(card_body(plotOutput("bg_plot", width = "100%", height = "100%"))),
      card(card_body(tableOutput("cross_table")))
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
  #   depth = 8,
  #   alpha = 0.05
  # ); input
  
  dxy <- reactive({
    
    set.seed(1234)
    
    dxy <- klassets::sim_response_xy(
      n = input$n,
      x_dist = purrr::partial(runif, min = -1, max = 1),
      relationship = function(x, y) eval(parse(text = input$relationship)),
      noise = input$percent_noise/100
    )
    
    dxy <- klassets::fit_classification_tree(
      dxy, 
      maxdepth = input$depth, 
      alpha = input$alpha
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
  
  output$tree_plot <- renderPlot({
    
    dxy <- dxy()
    
    plot(attr(dxy, "model"))
    
  })
  
  output$roc_plot <- renderPlot({
    
    dxy <- dxy()
    
    droc <- risk3r::roc_data(
      actual = as.numeric(dxy$response),
      predicted = 1 - dxy$prediction
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
  
  output$cross_table <- renderTable({
    
    dxy <- dxy()
    
    dxy2 <- klassets::fit_classification_tree(
      dxy, 
      type = "response",
      maxdepth = input$depth, 
      alpha = input$alpha
    )
    
    dxy2 |> 
      count(response, prediction) |> 
      mutate(
        p = percent(n/sum(n)),
        n = comma(n),
        lbl = str_glue("{n} ({p})"),
        prediction = str_glue("pred: {prediction}"),
        response  = str_glue("response: {response}")
        ) |> 
      select(-n, -p) |> 
      spread(prediction, lbl) |> 
      rename(` ` = response)
    
  })
  
}

shinyApp(ui, server)

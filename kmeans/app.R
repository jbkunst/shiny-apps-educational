# packages ----------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(klassets)
library(markdown)
library(ggforce)
library(deldir)

# theme options -----------------------------------------------------------
thematic::thematic_shiny(font = "auto")

theme_set(theme_minimal() + theme(legend.position = "bottom"))

apptheme <- bs_theme()

sidebar <- purrr::partial(bslib::sidebar, width = 300)

card <- purrr::partial(bslib::card, full_screen = TRUE)

primary_color <- unname(bs_get_variables(apptheme, c("primary")))

# app options -------------------------------------------------------------
KMAX <- 5

# ui ----------------------------------------------------------------------
ui <- page_fillable(
  theme = apptheme,
  padding = 0,
  layout_sidebar(
    fillable = TRUE,
    border = FALSE,
    sidebar = sidebar(
      # title = tags$h5("K-means"),
      title = "K-means",
      withMathJax(),
      tags$style(type = "text/css", ".irs-grid-pol.small {height: 0px;}"),
      
      # "Algorithm parameters",
      sliderInput(
        "k", tags$small("Parameter \\(k\\) for \\(K\\)-Means"), value = 4, min = 2, max = KMAX, ticks = TRUE
      ),
      # shinyWidgets::sliderTextInput(
      sliderInput(
        "iter",
        tags$small("Iterations of algorithm"), 
        # choices = 0:15,
        min = 1, max = 15,
        ticks = FALSE,
        value = 4, 
        animate = animationOptions(interval = 3000)
      ),
      accordion(
        multiple = FALSE,
        open = FALSE,
        accordion_panel(
          "Simulate data",
          sliderInput(
            "n_groups", tags$small("Number of groups to simulate"), value = 3, min = 1, max = KMAX
          ),
          sliderInput(
            "n", tags$small("Number of points to simulate"), value = 200, min = 100, max = 500, step = 100
          ),
          actionButton("button", "Generate", class = "btn-primary btn-sm")
          )
        ),
        tags$small(htmltools::includeMarkdown("readme.md"))
      ),
    layout_column_wrap(
      width = 1,
      height = "60%",
      card(
        card_header(uiOutput("iter")),
        card_body(plotOutput("iter_plot"))
        )
      ),
    # br(),
    layout_column_wrap(
      width = 1/4,
      height = "40%",
      card(card_body(tableOutput("iter_table"))),
      card(card_body(plotOutput("wc"))),
      card(card_body(plotOutput("convergence"))),
      card(card_body(plotOutput("elbow"))),
      )
    )
  )

# server ------------------------------------------------------------------
server <- function(input, output, session) {
  
  # input <- list(n_groups = 4, n = 150, k = 3, iter = 2); input
  # input <- list(n_groups = 3, n = 500, k = 5, iter = 2); input
  # input <- list(n_groups = 3, n = 200, k = 4, iter = 2); input
  
  output$iter <- renderUI({
    str_glue("Iteration #{input$iter}: {input$k} means ({input$n_groups} groups)")
  })
  
  data <- reactive({
    
    input$button
    
    set.seed(123)
    
    data <- klassets::sim_groups(n = isolate(input$n), groups = isolate(input$n_groups))
    
    data
    
  })
  
  # k means iterations all
  kmi_all <- reactive({
    
    data <- data()
    
    showNotification(str_glue("Calculating internal iterations"))
    
    kmi_all <- map(1:KMAX, function(k){
      cli::cli_inform(str_glue("{k} centers"))
      klassets::kmeans_iterations(df = data, centers = k)
    })
    
    kmi_all
    
  })
  
  # k means iteration (for actual selected k)
  kmi <- reactive({
    
    kmi_all <- kmi_all()
    
    kmi <- kmi_all[[input$k]]
    
    updateSliderInput(
        inputId = "iter",
        max = max(kmi$centers$iteration),
        # value = 1
        value = sample(1:max(kmi$center$iteration), size = 1)
    )
    
    kmi
    
  })
  
  # kmi_plot <- reactive({
  #   
  #   kmi <- kmi()
  #   
  #   kmi_plot <- plot(kmi)
  #   
  #   kmi_plot
  #   
  # })
  
  data_hist_all <- reactive({
    
    kmi_all <- kmi_all()
    
    ks <- 1:KMAX
    
    data_hist_all <- kmi_all |> 
      map(pluck, "points") |> 
      # map(filter, iteration == max(iteration)) |> 
      # map(select, -iteration, -id) |> 
      map2_df(ks, ~ mutate(.x, k = .y, .before = 1))
    
    data_hist_all <- data_hist_all |> 
      # filter(k == 2) |> 
      # distance from cluster
      group_by(k, iteration, cluster) |> 
      mutate(xc = mean(x), yc = mean(y)) |> 
      mutate(dc = (x - xc)^2 + (y - yc)^2) |> 
      # distance from total center
      ungroup() |> 
      group_by(k, iteration) |> 
      mutate(xt = mean(x), yt = mean(y)) |> 
      mutate(dt = (x - xt)^2 + (y - yt)^2) |> 
      ungroup()
    
    data_hist_all
    
  })
  
  data_elbow <- reactive({
    
    data_hist_all <- data_hist_all()
    
    data_elbow <- data_hist_all |> 
      group_by(k, iteration) |> 
      summarise(dc = sum(dc), dt = sum(dt), .groups = "drop") |> 
      mutate(wc = 1 - dc/dt) |> 
      ungroup()
    
    data_elbow
    
  })
  
  output$iter_plot <- renderPlot({
    
    # kmi_plot <- kmi_plot()
    # 
    # kmi_plot +
    #   ggforce::facet_wrap_paginate(
    #     vars(iteration),
    #     nrow = 1,
    #     ncol = 1,
    #     page = input$iter + 0
    #   )
    
    kmi <- kmi()
    
    dpoints  <- kmi$points  |> filter(iteration == input$iter)
    dcenters <- kmi$centers |> filter(iteration == input$iter - 1)
    
    # xmin, xmax, ymin, ymax.
    bnd <- dpoints |>
      summarise(
        x1 = min(pretty(dpoints$x)),
        x2 = max(pretty(dpoints$x)),
        y1 = min(pretty(dpoints$y)),
        y2 = max(pretty(dpoints$y))
      ) |> 
      pivot_longer(cols = everything()) |> 
      pull(value)
    
    bnd
    
    k      <- nrow(dplyr::count(dcenters, cluster))
    colors <- viridisLite::viridis(k, begin = 0.1, end = 0.9)
    colors <- purrr::set_names(colors, LETTERS[seq_len(k)])
    
    p <- ggplot() +
      ggforce::geom_voronoi_segment(
        data = dcenters,
        aes(cx, cy),
        alpha = 0.2, bound = bnd
      ) +
      geom_point(
        data = dpoints,
        aes(x, y, group = id, color = cluster, shape = group),
        size = 2#, alpha = 0.5
        ) + 
      geom_point(
        data = dcenters,
        aes(cx, cy, group = cluster, fill = cluster),
        size = 7, alpha = 1, shape = 21, show.legend = FALSE, color = "white"
        ) + 
      labs(
        shape = "Original\nGroup",
        color = "Assigned\nCluster",
        x = NULL,
        y = NULL
        ) +
      scale_color_manual(values = colors, name = "Assigned\nCluster", na.value = "gray70") +
      scale_fill_manual(values = colors, name = "Assigned\nCluster", na.value = "gray70") +
      theme(legend.position = "right")
    
    p
    
  })
  
  output$iter_table <- renderTable({
    
    kmi <- kmi()
    
    dpoints  <- kmi$points  |> filter(iteration == input$iter)
    
    dpoints |> 
      count(group, cluster) |> 
      mutate(
        group = str_glue("G{group}"),
        cluster =  fct_na_value_to_level(cluster, "0"),
        cluster = str_glue("Clus{cluster}"),
      ) |> 
      complete(group, cluster, fill = list(n = 0)) |> 
      spread(group, n) |> 
      rename(` ` = cluster)
    
  }, width = "100%")
  
  output$wc <- renderPlot({
    
    data_hist_all <- data_hist_all()
    
    dwck <- data_hist_all |>
      filter(k == input$k) |>
      group_by(iteration, cluster) |>
      summarise(wck = sum(dc), .groups = "drop")
    
    k      <- input$k
    colors <- viridisLite::viridis(k, begin = 0.1, end = 0.9)
    colors <- purrr::set_names(colors, LETTERS[seq_len(k)])
    
    ggplot(dwck) +
      geom_vline(aes(xintercept = input$iter), linewidth = 3, alpha = 0.25, color = primary_color) +
      geom_col(aes(iteration, wck, fill = cluster), position = position_stack()) +
      scale_x_continuous(breaks = unique(dwck$iteration), minor_breaks = NULL) +
      scale_fill_manual(values = colors, name = "", na.value = "gray90") +
      labs(y = expression("Sum of W(C_k)")) +
      theme(legend.position = "none")
    
  })
  
  output$convergence <- renderPlot({
    
    data_elbow <- data_elbow()
    
    daux <- data_elbow |> 
      filter(k == input$k, iteration > 0) |> 
      ungroup()
    
    # ggplot(data_elbow, aes(iteration, 1 - wc)) +
    #   geom_line(size = 1.2, color = "gray60") +
    #   facet_wrap(vars(k)) +
    #   scale_y_continuous(limits = c(0, 1))
    
    ggplot(daux, aes(iteration, 1 - wc)) +
      geom_line(linewidth = 1.2, color = "gray60") +
      geom_point(
        data = filter(daux, iteration == input$iter),
        shape = 21, 
        size = 5,
        color = "white", 
        fill = primary_color
      ) +
      scale_x_continuous(breaks = daux$iteration, minor_breaks = NULL) +
      scale_y_continuous(limits = c(0, 1))
    
  })
  
  output$elbow <- renderPlot({
    
    data_elbow <- data_elbow()
    
    daux <- data_elbow |> 
      group_by(k) |> 
      filter(iteration == max(iteration)) |> 
      ungroup()
    
    # ggplot(data_elbow, aes(k, 1 - wc)) +
    #   geom_line(size = 1.2, color = "gray60") +
    #   # kunstomverse::geom_point2
    #   geom_point(
    #     data = filter(daux, k == input$k),
    #     shape = 21, 
    #     size = 5,
    #     color = "white", 
    #     fill = primary_color
    #   ) +
    #   scale_x_continuous(breaks = 1:10, minor_breaks = NULL) +
    #   facet_wrap(vars(iteration))
   
    
    ggplot(daux, aes(k, 1 - wc)) +
      geom_line(linewidth = 1.2, color = "gray60") +
      # kunstomverse::geom_point2
      geom_point(
        data = filter(daux, k == input$k),
        shape = 21, 
        size = 5,
        color = "white", 
        fill = primary_color
      ) +
      scale_x_continuous(breaks = 1:10, minor_breaks = NULL) +
      scale_y_continuous(limits = c(0, 1))
    
  })
  
}

shinyApp(ui, server)

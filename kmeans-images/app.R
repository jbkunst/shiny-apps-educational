# packages ----------------------------------------------------------------
library(shiny)
library(bslib)
library(tidyverse)
library(scales)
library(jpeg)
library(imager)
# library(threejs) # devtools::install_github("bwlewis/rthreejs")
library(plotly)
library(markdown) # htmltools::includeMarkdown
library(shinyWidgets)

# theme options -----------------------------------------------------------
thematic::thematic_shiny(font = "auto")

theme_set(theme_minimal() + theme(legend.position = "bottom"))

apptheme <- bs_theme()

sidebar <- purrr::partial(bslib::sidebar, width = 300)

card <- purrr::partial(bslib::card, full_screen = TRUE)
 
# app options -------------------------------------------------------------
img_choices <- setNames(
  dir("www/imgs/", full.names = TRUE),
  str_to_title(gsub("\\.jpg$|\\.jpeg$|", "", dir("www/imgs/")))
)

# ui ----------------------------------------------------------------------
ui <- page_fillable(
  theme = apptheme,
  padding = 0,
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      title = "K-means on images",
      withMathJax(),
      selectizeInput(
        "image_file",
        tags$span("Image"),
        choices = sample(img_choices), 
        width = "100%"
      ),
      shinyWidgets::sliderTextInput(
        "k",
        tags$span("Parameter \\(k\\) for \\(K\\)-Means"),
        grid = TRUE,
        force_edges = TRUE,
        selected = 6,
        choices = c(1:10, 20, 50, 100, 500)
      ),
      checkboxInput("use_xy", tags$small("Use pixel position for clustering \\((r_i, g_i, b_i, x_i, y_i)\\)")),
      checkboxInput("scale", tags$small("Scale to \\([0, 1]\\) all columns before kmeans")),
      checkboxInput("show_axes", tags$small("Show image axes")),
      tags$small(htmltools::includeMarkdown("readme.md"))
      ),
    
    layout_columns(
      col_widths = 4,
      row_heights = 1,
      card(
        card_header("Image"),
        card_body(plotOutput("originalImage"))
        ),
      card(
        card_header("Color distribution"),
        card_body(plotOutput("originalColorDist"))
        ),
      card(
        card_header(tags$small("3D Scatter plot of sample of pixels")),
        card_body(plotlyOutput("scatterplot3d"))
        ),
      card(
        card_header("Result Image"),
        card_body(plotOutput("resultImage"))
        ),
      card(
        card_header("Result color distribution"),
        card_body(plotOutput("resultColorDist"))
        ),
      card(
        card_header(tags$small("3D Scatter plot from result image")),
        card_body(plotlyOutput("scatterplot3dresults"))
        )
      )
    )
  )

# server ------------------------------------------------------------------
server <- function(input, output, session) {
  
  # input <- list(
  #   image_file = "imgs/chess.jpg",
  #   k = 4,
  #   use_xy = FALSE,
  #   scale = FALSE,
  #   show_axes = FALSE
  #   ); input
  # 
  # input <- list(
  #   image_file = sample(img_choices, 1),
  #   k = sample(1:10, size = 1),
  #   use_xy = TRUE,
  #   scale = FALSE,
  #   show_axes = FALSE
  #   ); input
  
  image <- reactive({
    
    # image <- readJPEG(input$image_file)
    
    image <- load.image(here::here(input$image_file))
    image
    
  })
  
  df_image <- reactive({
    
    # image <- image()
    
    image <- readJPEG(input$image_file)
    
    cli::cli_alert_info("processing image {input$image_file}")
    
    df_image <- map(1:3, function(i) image[,,i]) %>% 
      map(function(m) {
        # m <- matrix(round(runif(12), 2), nrow = 4)
        m |> 
          as.data.frame() |> 
          as_tibble() |> 
          mutate(y = row_number()) |> 
          gather(x, c, -y) |> 
          mutate(
            x = as.numeric(gsub("V", "", x)),
            y = rev(y)
          ) |> 
          select(x, y, c)
      }) %>% 
      reduce(left_join, by = c("x", "y")) %>% 
      rename(r = c.x, g = c.y, b = c) %>% 
      mutate(rgb = rgb(r, g, b)) 
    
    df_image
    
  })
  
  df_image_kmeans <- reactive({
    
    cli::cli_inform("running stats::kmeans")
    
    df_image <- df_image()
    
    df_image_input <- df_image |> 
      select(r, g, b, x, y)
    
    if(!input$use_xy) {
      df_image_input <- df_image_input |> 
        select(-x, -y)
    }
    
    if(input$scale){
      df_image_input <- df_image_input |> 
        mutate(across(everything(), .fns = ~ scales::rescale(.x, to = c(0, 1))))
    }
    
    kMeans <- kmeans(df_image_input, centers = as.integer(input$k))
    
    df_image_kmeans <- df_image %>%
      mutate(
        rgb_app= rgb(kMeans$centers[kMeans$cluster, c("r", "g", "b")])
      )
    
    df_image_kmeans2 <- df_image_kmeans |>
      pull(rgb_app) |>
      # head() |>
      col2rgb() |>
      t() |>
      as_tibble() |>
      mutate(across(everything(), ~ ./255)) |>
      set_names(c("r", "g", "b")) |>
      rename_with(~ str_c(., "_app"), .cols = everything())
    
    df_image_kmeans <- bind_cols(df_image_kmeans, df_image_kmeans2)
    
    df_image_kmeans
    
  })
  
  output$originalImage <- renderPlot({
    
    # df_image <- df_image()
    # 
    # plot(
    #   df_image$x,
    #   df_image$y,
    #   col = df_image$rgb,
    #   asp = 1,
    #   pch = ".",
    #   ylab = "",
    #   xlab = "",
    #   xaxt = "n",
    #   yaxt = "n",
    #   axes = TRUE
    # )
    
    image <- image()
    
    plot(image, axes = input$show_axes)
    
  })
  
  output$originalColorDist <- renderPlot({
    
    df_image <- df_image()
    
    daux <- df_image %>%
      count(rgb) |>
      arrange(desc(n)) |> 
      mutate(
        rgb = fct_inorder(rgb),
        rgb = fct_lump_n(rgb, n = 20, w = n)
      ) |> 
      count(rgb, wt = n) |> 
      mutate(proportion = n/sum(n))
    
    cols <- daux |> 
      mutate(
        col = as.character(rgb),
        col = ifelse(col == "Other", "transparent", col),
      ) |> 
      select(rgb, col) |> 
      deframe()
    
    cols
    
    ggplot(daux) +
      geom_bar(aes(y = fct_rev(rgb), x = proportion, fill = rgb), color = "grey90", stat = "identity") +
      scale_fill_manual(values = cols, guide = "none") +
      # scale_x_continuous(labels = scales::percent) +
      scale_x_sqrt(labels = scales::percent) +
      labs(x = NULL, y = NULL) 
    
  })
  
  output$scatterplot3d <- renderPlotly({
    
    df_image <- df_image()
    
    set.seed(123)
    
    daux <- df_image |> 
      sample_n(1000) |> 
      mutate(across(c(r,g, b), function(x) round(x, 2))) |> 
      mutate(label = sprintf("rgb (%s, %s, %s)", r, g, b))
    
    plot_ly(
      data = daux,
      x = ~r,
      y = ~g,
      z = ~b,
      type = "scatter3d",
      mode = "markers",
      marker = list(
        color = ~rgb, # Assuming `rgb` is in a format compatible with plotly, e.g., hex colors
        symbol = "circle"
      ),
      text = ~label # Tooltip text
    )
    
    
  })
  
  output$resultImage <- renderPlot({
    
    df_image_kmeans <- df_image_kmeans()
    image           <- image()
    
    daux <- df_image_kmeans |>
      mutate(y = max(y) - y + 1) |>
      filter(TRUE) |>
      mutate()
    
    image_result <- image
    
    image_result[,,,1] <- daux |> select(x, y, r_app) |> spread(y, r_app) |> select(-x) |> as.matrix()
    image_result[,,,2] <- daux |> select(x, y, g_app) |> spread(y, g_app) |> select(-x) |> as.matrix()
    image_result[,,,3] <- daux |> select(x, y, b_app) |> spread(y, b_app) |> select(-x) |> as.matrix()
    
    plot(image_result, axes = input$show_axes)
    
    # plot(
    #   df_image_kmeans$x,
    #   df_image_kmeans$y,
    #   col = df_image_kmeans$rgb_app,
    #   asp = 1,
    #   pch = ".",
    #   ylab = "",
    #   xlab = "",
    #   xaxt = "n",
    #   yaxt = "n",
    #   input$show_axes
    # )
    
  })
  
  output$resultColorDist <- renderPlot({
    
    df_image_kmeans <- df_image_kmeans()
    
    daux <- df_image_kmeans %>%
      count(rgb = rgb_app) |>
      arrange(desc(n)) |> 
      mutate(
        rgb = fct_inorder(rgb),
        rgb = fct_lump_n(rgb, n = 20, w = n)
      ) |> 
      count(rgb, wt = n) |> 
      mutate(proportion = n/sum(n))
    
    cols <- daux |> 
      mutate(
        col = as.character(rgb),
        col = ifelse(col == "Other", "transparent", col),
      ) |> 
      select(rgb, col) |> 
      deframe()
    
    cols
    
    ggplot(daux) +
      geom_bar(aes(y = fct_rev(rgb), x = proportion, fill = rgb), color = "grey90", stat = "identity") +
      scale_fill_manual(values = cols, guide = "none") +
      scale_x_continuous(labels = scales::percent) +
      labs(x = NULL, y = NULL)
  })
  
  output$scatterplot3dresults <- renderPlotly({
    
    df_image_kmeans <- df_image_kmeans()
    
    set.seed(123)
    
    daux <- df_image_kmeans |> 
      sample_n(1000) |> 
      mutate(across(c(r,g, b), function(x) round(x, 2))) |> 
      mutate(across(c(r_app, g_app, b_app), function(x) round(x, 2))) |> 
      mutate(
        label = sprintf("rgb (%s, %s, %s)", r, g, b),
        label_app = sprintf("rgb (%s, %s, %s)", r_app, g_app, b_app),
        )
    
    plot_ly(
      data = daux,
      x = ~r,
      y = ~g,
      z = ~b,
      type = "scatter3d",
      mode = "markers",
      marker = list(
        color = ~rgb_app, # Assuming `rgb` is in a format compatible with plotly, e.g., hex colors
        symbol = "circle"
      ),
      text = ~ glue::glue("{label_app}\n{label}")# Tooltip text
    )
    
  })
  
}

shinyApp(ui, server)

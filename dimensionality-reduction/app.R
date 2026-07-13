# packages ----------------------------------------------------------------
library(shiny)
library(bslib)
library(dplyr)
library(purrr)
library(tibble)
library(plotly)
library(Rtsne)
library(uwot)
library(vegan)

# theme options -----------------------------------------------------------
thematic::thematic_shiny(font = "auto")

apptheme <- bs_theme()

sidebar <- purrr::partial(bslib::sidebar, width = 300)
card <- purrr::partial(bslib::card, full_screen = TRUE)

class_colors <- unname(
  bs_get_variables(
    apptheme,
    c("primary", "danger", "success", "warning", "info")
  )
)

# app options -------------------------------------------------------------
N_MAX <- 1000
D_MAX <- 20

DATASET_HELP <- c(
  gaussian = paste(
    "Three Gaussian groups. This is the easy reference case:",
    "the classes are real and roughly linearly separated."
  ),
  moons = paste(
    "Two curved groups. The classes are real, but their shape is nonlinear."
  ),
  circles = paste(
    "Two concentric groups. The classes are real, although one surrounds the other."
  ),
  swiss_roll = paste(
    "A rolled two-dimensional surface inside a higher-dimensional space.",
    "Color shows position along the roll; it is not a class."
  )
)

# helpers -----------------------------------------------------------------
include_md <- function(path) {
  if (file.exists(path)) {
    htmltools::includeMarkdown(path)
  } else {
    NULL
  }
}

safe_scale <- function(x) {
  x <- as.matrix(x)
  center <- colMeans(x)
  spread <- apply(x, 2, stats::sd)

  spread[!is.finite(spread) | spread == 0] <- 1

  x <- sweep(x, 2, center, FUN = "-")
  sweep(x, 2, spread, FUN = "/")
}

generate_latent_data <- function(type, n, noise) {
  if (type == "gaussian") {
    group <- sample(1:3, size = n, replace = TRUE)
    centers <- rbind(
      c(-2.2, -1.3),
      c(2.2, -1.3),
      c(0.0, 2.2)
    )

    latent <- centers[group, , drop = FALSE] +
      matrix(stats::rnorm(2 * n, sd = 0.55 + noise), ncol = 2)

    return(list(
      latent = latent,
      group = factor(group, labels = paste("Group", 1:3)),
      color_value = rep(NA_real_, n),
      color_type = "class"
    ))
  }

  if (type == "moons") {
    group <- sample(1:2, size = n, replace = TRUE)
    angle <- stats::runif(n, 0, pi)

    latent <- matrix(NA_real_, nrow = n, ncol = 2)

    first <- group == 1
    latent[first, ] <- cbind(
      cos(angle[first]),
      sin(angle[first])
    )
    latent[!first, ] <- cbind(
      1 - cos(angle[!first]),
      0.45 - sin(angle[!first])
    )

    latent <- latent +
      matrix(stats::rnorm(2 * n, sd = 0.04 + noise / 3), ncol = 2)

    return(list(
      latent = latent,
      group = factor(group, labels = c("Moon 1", "Moon 2")),
      color_value = rep(NA_real_, n),
      color_type = "class"
    ))
  }

  if (type == "circles") {
    group <- sample(1:2, size = n, replace = TRUE)
    angle <- stats::runif(n, 0, 2 * pi)
    radius <- ifelse(group == 1, 1, 2)

    latent <- cbind(
      radius * cos(angle),
      radius * sin(angle)
    )

    latent <- latent +
      matrix(stats::rnorm(2 * n, sd = 0.04 + noise / 3), ncol = 2)

    return(list(
      latent = latent,
      group = factor(group, labels = c("Inner", "Outer")),
      color_value = rep(NA_real_, n),
      color_type = "class"
    ))
  }

  roll_position <- stats::runif(n, 1.5 * pi, 4.5 * pi)
  height <- stats::runif(n, -1, 1)

  latent <- cbind(
    roll_position * cos(roll_position),
    height * 7,
    roll_position * sin(roll_position)
  )

  latent <- latent +
    matrix(stats::rnorm(3 * n, sd = noise), ncol = 3)

  list(
    latent = latent,
    group = factor(rep(NA_character_, n)),
    color_value = roll_position,
    color_type = "continuous"
  )
}

expand_dimensions <- function(latent, dimensions, noise) {
  latent <- safe_scale(latent)
  latent_dimensions <- ncol(latent)

  projection <- matrix(
    stats::rnorm(latent_dimensions * dimensions),
    nrow = latent_dimensions,
    ncol = dimensions
  )

  observed <- latent %*% projection

  if (noise > 0) {
    observed <- observed +
      matrix(
        stats::rnorm(nrow(observed) * dimensions, sd = noise),
        nrow = nrow(observed),
        ncol = dimensions
      )
  }

  colnames(observed) <- paste0("x", seq_len(dimensions))
  safe_scale(observed)
}

generate_data <- function(type, n, dimensions, noise, seed) {
  set.seed(seed)

  generated <- generate_latent_data(
    type = type,
    n = n,
    noise = noise
  )

  observed <- expand_dimensions(
    latent = generated$latent,
    dimensions = dimensions,
    noise = noise
  )

  list(
    x = observed,
    metadata = tibble(
      row_id = seq_len(n),
      group = generated$group,
      color_value = generated$color_value,
      color_type = generated$color_type
    )
  )
}

run_pca <- function(x) {
  fit <- stats::prcomp(x, center = FALSE, scale. = FALSE)
  fit$x[, 1:2, drop = FALSE]
}

run_isomap <- function(x) {
  n <- nrow(x)
  first_k <- max(5, min(15, round(sqrt(n))))
  candidates <- unique(
    pmin(
      n - 1,
      c(
        seq(first_k, min(50, n - 1), by = 5),
        round(n * c(0.15, 0.25, 0.40)),
        n - 1
      )
    )
  )

  for (k in candidates) {
    fit <- try(
      vegan::isomap(
        stats::dist(x),
        ndim = 2,
        k = k
      ),
      silent = TRUE
    )

    if (
      !inherits(fit, "try-error") &&
      !is.null(fit$points) &&
      ncol(fit$points) >= 2
    ) {
      return(fit$points[, 1:2, drop = FALSE])
    }
  }

  stop("Isomap could not build a connected neighborhood graph.")
}

run_tsne <- function(x, seed) {
  set.seed(seed)

  perplexity <- min(30, floor((nrow(x) - 1) / 3))

  Rtsne::Rtsne(
    x,
    dims = 2,
    perplexity = perplexity,
    check_duplicates = FALSE,
    pca = TRUE,
    max_iter = 500,
    verbose = FALSE
  )$Y
}

run_umap <- function(x, seed) {
  set.seed(seed)

  uwot::umap(
    x,
    n_components = 2,
    n_neighbors = min(15, nrow(x) - 1),
    min_dist = 0.1,
    n_threads = 1,
    verbose = FALSE
  )
}

projection_data <- function(coordinates, metadata) {
  bind_cols(
    metadata,
    tibble(
      axis_1 = coordinates[, 1],
      axis_2 = coordinates[, 2]
    )
  )
}

projection_plot <- function(coordinates, metadata) {
  data <- projection_data(coordinates, metadata)

  if (identical(metadata$color_type[[1]], "continuous")) {
    data <- data |>
      mutate(
        tooltip = paste0(
          "Observation: ", row_id,
          "<br>Position along roll: ",
          round(color_value, 2)
        )
      )

    plot <- plot_ly(
      data,
      x = ~axis_1,
      y = ~axis_2,
      type = "scatter",
      mode = "markers",
      color = ~color_value,
      colors = "Viridis",
      text = ~tooltip,
      hoverinfo = "text",
      marker = list(size = 7, opacity = 0.8)
    )
  } else {
    data <- data |>
      mutate(
        tooltip = paste0(
          "Observation: ", row_id,
          "<br>Class: ", group
        )
      )

    plot <- plot_ly(
      data,
      x = ~axis_1,
      y = ~axis_2,
      type = "scatter",
      mode = "markers",
      color = ~group,
      colors = class_colors,
      text = ~tooltip,
      hoverinfo = "text",
      marker = list(size = 7, opacity = 0.8)
    )
  }

  plot |>
    layout(
      xaxis = list(title = "", zeroline = FALSE),
      yaxis = list(title = "", zeroline = FALSE),
      legend = list(
        orientation = "h",
        x = 0,
        y = -0.12
      ),
      margin = list(l = 35, r = 15, b = 45, t = 10),
      hovermode = "closest"
    ) |>
    config(displaylogo = FALSE)
}

# ui ----------------------------------------------------------------------
ui <- page_fillable(
  theme = apptheme,
  padding = 0,
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      title = "Dimensionality Reduction",

      selectInput(
        "dataset",
        tags$small("Example data"),
        choices = c(
          "Gaussian clusters" = "gaussian",
          "Two moons" = "moons",
          "Concentric circles" = "circles",
          "Swiss roll" = "swiss_roll"
        ),
        selected = "gaussian"
      ),

      uiOutput("dataset_help"),

      sliderInput(
        "n",
        tags$small("Number of observations"),
        min = 100,
        max = N_MAX,
        value = 400,
        step = 100
      ),

      sliderInput(
        "dimensions",
        tags$small("Observed dimensions"),
        min = 3,
        max = D_MAX,
        value = 8,
        step = 1
      ),

      sliderInput(
        "noise",
        tags$small("Noise"),
        min = 0,
        max = 0.6,
        value = 0.1,
        step = 0.05
      ),

      numericInput(
        "seed",
        tags$small("Random seed"),
        value = 123,
        min = 1,
        step = 1
      ),

      actionButton(
        "generate",
        "Generate",
        class = "btn-primary btn-sm"
      ),

      accordion(
        multiple = FALSE,
        open = FALSE,
        accordion_panel(
          "How it works",
          tags$small(include_md("readme.md"))
        )
      ),
      
      tags$small(include_md("credits.md"))
    ),

    layout_columns(
      col_widths = c(6, 6, 6, 6),
      row_heights = c(1, 1),

      card(
        card_header("PCA — maximum variance"),
        card_body(plotlyOutput("pca_plot", height = "100%"))
      ),

      card(
        card_header("Isomap — geodesic distances"),
        card_body(plotlyOutput("isomap_plot", height = "100%"))
      ),

      card(
        card_header("t-SNE — local neighborhoods"),
        card_body(plotlyOutput("tsne_plot", height = "100%"))
      ),

      card(
        card_header("UMAP — neighborhood graph"),
        card_body(plotlyOutput("umap_plot", height = "100%"))
      )
    )
  )
)

# server ------------------------------------------------------------------
server <- function(input, output, session) {
  output$dataset_help <- renderUI({
    tags$small(
      class = "text-muted",
      DATASET_HELP[[input$dataset]]
    )
  })

  results <- eventReactive(input$generate, {
    withProgress(message = "Generating projections", value = 0, {
      generated <- generate_data(
        type = input$dataset,
        n = input$n,
        dimensions = input$dimensions,
        noise = input$noise,
        seed = input$seed
      )

      incProgress(0.2, detail = "PCA")

      projections <- list()
      projections$pca <- run_pca(generated$x)

      incProgress(0.25, detail = "Isomap")
      projections$isomap <- run_isomap(generated$x)

      incProgress(0.25, detail = "t-SNE")
      projections$tsne <- run_tsne(
        generated$x,
        seed = input$seed + 1
      )

      incProgress(0.25, detail = "UMAP")
      projections$umap <- run_umap(
        generated$x,
        seed = input$seed + 2
      )

      incProgress(0.05)

      list(
        metadata = generated$metadata,
        projections = projections
      )
    })
  }, ignoreNULL = FALSE)

  output$pca_plot <- renderPlotly({
    result <- results()

    projection_plot(
      coordinates = result$projections$pca,
      metadata = result$metadata
    )
  })

  output$isomap_plot <- renderPlotly({
    result <- results()

    projection_plot(
      coordinates = result$projections$isomap,
      metadata = result$metadata
    )
  })

  output$tsne_plot <- renderPlotly({
    result <- results()

    projection_plot(
      coordinates = result$projections$tsne,
      metadata = result$metadata
    )
  })

  output$umap_plot <- renderPlotly({
    result <- results()

    projection_plot(
      coordinates = result$projections$umap,
      metadata = result$metadata
    )
  })
}

shinyApp(ui, server)

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
library(markdown)
library(shinyWidgets)

# theme options -----------------------------------------------------------
thematic::thematic_shiny(font = "auto")

apptheme <- bs_theme()

sidebar <- purrr::partial(bslib::sidebar, width = 300)
card <- purrr::partial(bslib::card, full_screen = TRUE)

# app options -------------------------------------------------------------
n_choices <- c("100", "200", "400", "700", "1000")
real_n_choices <- c("400", "1000", "2000")
mammoth_n_choices <- c("1000", "2000", "5000", "10000")
dimension_choices <- c("2", "3", "5", "8", "12", "20")
noise_choices <- c("0", "0.05", "0.10", "0.20", "0.40", "0.60")
neighbor_choices <- c("0", "3", "5", "8", "12", "20")

real_datasets <- c("mnist", "fashion_mnist", "mammoth")

real_dataset_files <- c(
  mnist = "mnist.rds",
  fashion_mnist = "fashion-mnist.rds",
  mammoth = "mammoth.rds"
)

DATASET_HELP <- c(
  mnist = paste(
    "Handwritten digits from MNIST.",
    "Each image is represented by pixel intensities and colored by digit."
  ),
  fashion_mnist = paste(
    "Fashion-MNIST images.",
    "Each image is represented by pixel intensities and colored by clothing category."
  ),
  mammoth = paste(
    "A 3D mammoth point cloud from the Understanding UMAP project.",
    "Color identifies the provided region label."
  ),
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

safe_scale <- function(x) {
  x <- as.matrix(x)
  center <- colMeans(x)
  spread <- apply(x, 2, stats::sd)

  spread[!is.finite(spread) | spread == 0] <- 1

  x <- sweep(x, 2, center, FUN = "-")
  sweep(x, 2, spread, FUN = "/")
}

scale_together <- function(x) {
  x <- as.matrix(x)
  x <- sweep(x, 2, colMeans(x), FUN = "-")
  spread <- max(apply(x, 2, stats::sd))

  if (!is.finite(spread) || spread == 0) {
    spread <- 1
  }

  x / spread
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
  round(safe_scale(observed), 3)
}

generate_data <- function(type, n, dimensions, noise, seed) {
  set.seed(seed)
  n <- as.integer(n)
  dimensions <- as.integer(dimensions)
  noise <- as.numeric(noise)

  if (type %in% real_datasets) {
    file <- file.path("data", real_dataset_files[[type]])

    if (!file.exists(file)) {
      file <- file.path("dimensionality-reduction", "data", real_dataset_files[[type]])
    }

    if (!file.exists(file)) {
      stop("Run download_data.R before using this real dataset.", call. = FALSE)
    }

    data <- readRDS(file)
    id <- sample(seq_len(nrow(data$x)), size = min(n, nrow(data$x)))

    observed <- as.matrix(data$x[id, , drop = FALSE])
    observed <- round(scale_together(observed), 3)

    label <- factor(data$label[id], levels = levels(factor(data$label)))

    return(list(
      x = observed,
      metadata = tibble(
        row_id = seq_along(id),
        group = label,
        color_value = rep(NA_real_, length(id)),
        color_type = "class"
      )
    ))
  }

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

isomap_input <- function(x, max_dimensions = 20) {
  x <- as.matrix(x)

  if (ncol(x) <= max_dimensions) {
    return(x)
  }

  fit <- stats::prcomp(
    x,
    center = FALSE,
    scale. = FALSE,
    rank. = max_dimensions
  )

  fit$x[, seq_len(min(max_dimensions, ncol(fit$x))), drop = FALSE]
}

nearest_landmark <- function(x, landmarks) {
  nearest <- integer(nrow(x))
  landmark_norm <- rowSums(landmarks^2)
  chunk_size <- 500

  for (first in seq(1, nrow(x), by = chunk_size)) {
    last <- min(first + chunk_size - 1, nrow(x))
    rows <- first:last
    chunk <- x[rows, , drop = FALSE]

    distances <- outer(rowSums(chunk^2), landmark_norm, "+") -
      2 * chunk %*% t(landmarks)

    nearest[rows] <- max.col(-distances)
  }

  nearest
}

run_isomap_exact <- function(x) {
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

run_isomap <- function(x, seed, landmark_n = 800) {
  set.seed(seed)

  x <- isomap_input(x)
  n <- nrow(x)

  if (n <= landmark_n) {
    return(run_isomap_exact(x))
  }

  landmark_id <- sort(sample(seq_len(n), landmark_n))
  landmarks <- x[landmark_id, , drop = FALSE]
  landmark_embedding <- run_isomap_exact(landmarks)

  nearest <- nearest_landmark(x, landmarks)
  embedding <- landmark_embedding[nearest, , drop = FALSE]
  embedding[landmark_id, ] <- landmark_embedding

  pca_offset <- run_pca(x)
  landmark_offset <- pca_offset[landmark_id[nearest], , drop = FALSE]
  local_offset <- pca_offset - landmark_offset

  embedding + 0.05 * local_offset
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

class_palette <- function(group) {
  levels <- levels(factor(group))
  palette <- viridisLite::viridis(length(levels), begin = 0.08, end = 0.82)

  palette[match(as.character(group), levels)]
}

projection_highlight_data <- function(coordinates, metadata, ids) {
  data <- projection_data(coordinates, metadata)

  if (length(ids) == 0) {
    data <- data[0, ]
  } else {
    data <- filter(data, .data$row_id %in% ids)
  }

  if (identical(metadata$color_type[[1]], "continuous")) {
    return(mutate(
      data,
      tooltip = paste0(
        "Observation: ", row_id,
        "<br>Position along roll: ", round(color_value, 2)
      )
    ))
  }

  mutate(
    data,
    tooltip = paste0(
      "Observation: ", row_id,
      "<br>Class: ", group
    )
  )
}

observed_highlight_data <- function(x, metadata, ids) {
  observed <- as_tibble(x, .name_repair = "minimal")
  names(observed) <- paste0("x", seq_len(ncol(x)))

  data <- bind_cols(metadata, observed)

  if (length(ids) == 0) {
    data <- data[0, ]
  } else {
    data <- filter(data, .data$row_id %in% ids)
  }

  if (identical(metadata$color_type[[1]], "continuous")) {
    return(mutate(
      data,
      tooltip = paste0(
        "Observation: ", row_id,
        "<br>Position: ", round(color_value, 2)
      )
    ))
  }

  mutate(
    data,
    tooltip = paste0(
      "Observation: ", row_id,
      "<br>Class: ", group
    )
  )
}

nearest_ids <- function(x, row_id, n_neighbors) {
  if (
    is.null(row_id) ||
    length(row_id) == 0 ||
    is.na(row_id) ||
    !is.finite(row_id) ||
    is.null(n_neighbors) ||
    n_neighbors == 0
  ) {
    return(integer())
  }

  row_id <- as.integer(row_id)
  n_neighbors <- as.integer(n_neighbors)
  distances <- rowSums(sweep(x, 2, x[row_id, ], FUN = "-")^2)
  ids <- order(distances)

  head(setdiff(ids, row_id), n_neighbors)
}

observed_table <- function(x, metadata, selected_id, neighbor_ids) {
  observed <- as_tibble(x, .name_repair = "minimal")
  names(observed) <- paste0("x", seq_len(ncol(x)))

  selected <- integer()

  if (
    !is.null(selected_id) &&
    length(selected_id) > 0 &&
    !is.na(selected_id) &&
    is.finite(selected_id)
  ) {
    selected <- as.integer(selected_id)
  }

  data <- bind_cols(
    tibble(row_id = metadata$row_id),
    observed
  ) |>
    mutate(
      role = case_when(
        .data$row_id %in% selected ~ "selected",
        .data$row_id %in% neighbor_ids ~ "neighbor",
        TRUE ~ "other"
      )
    ) |>
    relocate("row_id", "role")

  if (length(selected) > 0) {
    data <- filter(data, .data$role != "other")
  } else {
    data <- slice_head(data, n = 20)
  }

  data |>
    mutate(across(where(is.numeric), function(x) round(x, 3))) |>
    mutate(row_id = as.integer(.data$row_id))
}

equal_3d_ranges <- function(data) {
  ranges <- list(
    x = range(data$x1, na.rm = TRUE),
    y = range(data$x2, na.rm = TRUE),
    z = range(data$x3, na.rm = TRUE)
  )

  centers <- vapply(ranges, mean, numeric(1))
  half_width <- max(vapply(ranges, diff, numeric(1))) / 2

  list(
    x = centers[["x"]] + c(-half_width, half_width),
    y = centers[["y"]] + c(-half_width, half_width),
    z = centers[["z"]] + c(-half_width, half_width)
  )
}

observed_plot <- function(x, metadata) {
  observed <- as_tibble(x, .name_repair = "minimal")
  names(observed) <- paste0("x", seq_len(ncol(x)))

  data <- bind_cols(
    metadata,
    observed
  )

  dims <- ncol(x)

  if (identical(metadata$color_type[[1]], "continuous")) {
    data <- data |>
      mutate(
        tooltip = paste0(
          "Observation: ", row_id,
          "<br>Position: ", round(color_value, 2)
        )
      )

    plot <- plot_ly(
      data,
      x = ~x1,
      y = ~x2,
      z = if (dims == 3) ~x3 else NULL,
      type = if (dims == 3) "scatter3d" else "scatter",
      mode = "markers",
      color = ~color_value,
      colors = viridisLite::viridis(256),
      source = "observed",
      key = ~row_id,
      text = ~tooltip,
      hoverinfo = "text",
      marker = list(size = if (dims == 3) 3 else 7, opacity = 0.65)
    )
  } else {
    data <- data |>
      mutate(
        point_color = class_palette(.data$group),
        tooltip = paste0(
          "Observation: ", row_id,
          "<br>Class: ", group
        )
      )

    plot <- plot_ly(
      data,
      x = ~x1,
      y = ~x2,
      z = if (dims == 3) ~x3 else NULL,
      type = if (dims == 3) "scatter3d" else "scatter",
      mode = "markers",
      source = "observed",
      key = ~row_id,
      text = ~tooltip,
      hoverinfo = "text",
      marker = list(
        size = if (dims == 3) 3 else 7,
        opacity = 0.65,
        color = data$point_color
      )
    )
  }

  empty <- data[0, ]

  plot <- plot |>
    add_trace(
      data = empty,
      x = ~x1,
      y = ~x2,
      z = if (dims == 3) ~x3 else NULL,
      type = if (dims == 3) "scatter3d" else "scatter",
      mode = "markers",
      inherit = FALSE,
      key = ~row_id,
      text = ~tooltip,
      hoverinfo = "text",
      marker = list(
        size = if (dims == 3) 5 else 13,
        color = "rgba(255, 193, 7, 0.65)",
        line = list(color = "#111827", width = 1)
      ),
      showlegend = FALSE
    ) |>
    add_trace(
      data = empty,
      x = ~x1,
      y = ~x2,
      z = if (dims == 3) ~x3 else NULL,
      type = if (dims == 3) "scatter3d" else "scatter",
      mode = "markers",
      inherit = FALSE,
      key = ~row_id,
      text = ~tooltip,
      hoverinfo = "text",
      marker = list(
        size = if (dims == 3) 7 else 16,
        color = "#111827",
        line = list(color = "#FFFFFF", width = 2)
      ),
      showlegend = FALSE
    )

  if (dims == 3) {
    ranges <- equal_3d_ranges(data)

    plot |>
      layout(
        scene = list(
          xaxis = list(title = "x1", range = ranges$x),
          yaxis = list(title = "x2", range = ranges$y),
          zaxis = list(title = "x3", range = ranges$z),
          aspectmode = "cube"
        ),
        margin = list(l = 0, r = 0, b = 0, t = 0)
      ) |>
      config(displaylogo = FALSE)
  } else {
    plot |>
      layout(
        xaxis = list(title = "x1", zeroline = FALSE),
        yaxis = list(title = "x2", zeroline = FALSE),
        margin = list(l = 45, r = 20, b = 45, t = 10),
        hovermode = "closest"
      ) |>
      config(displaylogo = FALSE)
  }
}

projection_plot <- function(
  coordinates,
  metadata,
  source
) {
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
      colors = viridisLite::viridis(256),
      source = source,
      key = ~row_id,
      text = ~tooltip,
      hoverinfo = "text",
      marker = list(size = 7, opacity = 0.8)
    )
  } else {
    data <- data |>
      mutate(
        point_color = class_palette(.data$group),
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
      source = source,
      key = ~row_id,
      text = ~tooltip,
      hoverinfo = "text",
      marker = list(size = 7, opacity = 0.8, color = data$point_color)
    )
  }

  empty <- data[0, ]

  plot <- plot |>
    add_trace(
      data = empty,
      x = ~axis_1,
      y = ~axis_2,
      type = "scatter",
      mode = "markers",
      inherit = FALSE,
      key = ~row_id,
      text = ~tooltip,
      hoverinfo = "text",
      marker = list(
        size = 13,
        color = "rgba(255, 193, 7, 0.55)",
        line = list(color = "#111827", width = 1)
      ),
      showlegend = FALSE
    ) |>
    add_trace(
      data = empty,
      x = ~axis_1,
      y = ~axis_2,
      type = "scatter",
      mode = "markers",
      inherit = FALSE,
      key = ~row_id,
      text = ~tooltip,
      hoverinfo = "text",
      marker = list(
        size = 16,
        color = "#111827",
        line = list(color = "#FFFFFF", width = 2)
      ),
      showlegend = FALSE
    )
    
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
  tags$head(
    tags$style(
      htmltools::HTML(".selectize-dropdown-content { max-height: none !important; }")
    )
  ),
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      title = "Dimensionality Reduction",

      selectizeInput(
        "dataset",
        tags$small("Type of data"),
        choices = list(
          "Real data" = c(
            "MNIST digits" = "mnist",
            "Fashion-MNIST" = "fashion_mnist",
            "Mammoth point cloud" = "mammoth"
          ),
          "Simulated data" = c(
            "Gaussian clusters" = "gaussian",
            "Two moons" = "moons",
            "Concentric circles" = "circles",
            "Swiss roll" = "swiss_roll"
          )
        ),
        selected = "gaussian",
        options = list(maxOptions = 20)
      ),

      uiOutput("dataset_help"),
      uiOutput("n_input"),
      uiOutput("simulation_controls"),

      div(
        class = "d-flex flex-wrap gap-2",
        actionButton(
          "generate",
          "Generate",
          class = "btn-primary btn-sm"
        ),
        actionButton(
          "show_observed",
          "Observed data",
          class = "btn-outline-primary btn-sm"
        )
      ),

      sliderTextInput(
        "neighbors",
        tags$small("Neighbors to highlight"),
        choices = neighbor_choices,
        selected = "8",
        grid = TRUE,
        force_edges = TRUE
      ),

      div(
        class = "d-flex align-items-start justify-content-between gap-2",
        uiOutput("highlight_status"),
        actionButton(
          "clear_highlight",
          "Clear",
          class = "btn-outline-secondary btn-sm"
        )
      ),

      accordion(
        multiple = FALSE,
        open = FALSE,
        accordion_panel(
          "How it works",
          tags$small(htmltools::includeMarkdown("readme.md"))
        ),
        accordion_panel(
          "Further reading",
          tags$small(htmltools::includeMarkdown("resources.md"))
        )
      ),
      
      tags$small(htmltools::includeMarkdown("credits.md"))
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

  output$n_input <- renderUI({
    is_real <- input$dataset %in% real_datasets
    choices <- if (input$dataset == "mammoth") {
      mammoth_n_choices
    } else if (is_real) {
      real_n_choices
    } else {
      n_choices
    }

    selected <- if (input$dataset == "mammoth") {
      "5000"
    } else if (is_real) {
      "1000"
    } else {
      "400"
    }

    label <- if (is_real) {
      "Observations to sample"
    } else {
      "Observations to simulate"
    }

    sliderTextInput(
      "n",
      tags$small(label),
      choices = choices,
      selected = selected,
      grid = TRUE,
      force_edges = TRUE
    )
  })

  output$simulation_controls <- renderUI({
    if (input$dataset %in% real_datasets) {
      return(NULL)
    }

    tagList(
      sliderTextInput(
        "dimensions",
        tags$small("Observed dimensions"),
        choices = dimension_choices,
        selected = "8",
        grid = TRUE,
        force_edges = TRUE
      ),
      sliderTextInput(
        "noise",
        tags$small("Noise"),
        choices = noise_choices,
        selected = "0.10",
        grid = TRUE,
        force_edges = TRUE
      )
    )
  })

  results <- reactiveVal(NULL)
  selected_id <- reactiveVal(NULL)

  calculate_results <- function() {
    isolate(withProgress(message = "Generating projections", value = 0, {
      req(input$dataset, input$n)

      seed <- sample.int(1e6, 1)
      dimensions <- if (is.null(input$dimensions)) 8 else as.integer(input$dimensions)
      noise <- if (is.null(input$noise)) 0 else as.numeric(input$noise)

      generated <- generate_data(
        type = input$dataset,
        n = as.integer(input$n),
        dimensions = dimensions,
        noise = noise,
        seed = seed
      )

      incProgress(0.2, detail = "PCA")

      projections <- list()
      projections$pca <- run_pca(generated$x)

      incProgress(0.25, detail = "Isomap")
      projections$isomap <- run_isomap(
        generated$x,
        seed = seed + 3
      )

      incProgress(0.25, detail = "t-SNE")
      projections$tsne <- run_tsne(
        generated$x,
        seed = seed + 1
      )

      incProgress(0.25, detail = "UMAP")
      projections$umap <- run_umap(
        generated$x,
        seed = seed + 2
      )

      incProgress(0.05)

      list(
        observed = generated$x,
        metadata = generated$metadata,
        projections = projections
      )
    }))
  }

  observeEvent(input$n, {
    selected_id(NULL)
    results(calculate_results())
  }, ignoreNULL = TRUE, once = TRUE)

  observeEvent(input$generate, {
    selected_id(NULL)
    results(calculate_results())
  }, ignoreInit = TRUE)

  observeEvent(input$clear_highlight, {
    selected_id(NULL)
  })

  select_point <- function(click) {
    if (is.null(click$key) || length(click$key) == 0 || is.na(click$key[[1]])) {
      return(invisible(NULL))
    }

    selected_id(as.integer(click$key[[1]]))
  }

  observeEvent(event_data("plotly_click", source = "pca"), {
    click <- event_data("plotly_click", source = "pca")
    select_point(click)
  }, ignoreNULL = TRUE)

  observeEvent(event_data("plotly_click", source = "isomap"), {
    click <- event_data("plotly_click", source = "isomap")
    select_point(click)
  }, ignoreNULL = TRUE)

  observeEvent(event_data("plotly_click", source = "tsne"), {
    click <- event_data("plotly_click", source = "tsne")
    select_point(click)
  }, ignoreNULL = TRUE)

  observeEvent(event_data("plotly_click", source = "umap"), {
    click <- event_data("plotly_click", source = "umap")
    select_point(click)
  }, ignoreNULL = TRUE)

  observeEvent(event_data("plotly_click", source = "observed"), {
    click <- event_data("plotly_click", source = "observed")
    select_point(click)
  }, ignoreNULL = TRUE)

  neighbor_ids <- reactive({
    result <- results()
    req(result)

    nearest_ids(
      x = result$observed,
      row_id = selected_id(),
      n_neighbors = input$neighbors
    )
  })

  output$highlight_status <- renderUI({
    id <- selected_id()

    if (is.null(id)) {
      return(tags$small(class = "text-muted", "Click a point in any map."))
    }

    tags$small(
      class = "text-muted",
      paste0("Observation ", id, " + ", length(neighbor_ids()), " observed neighbors.")
    )
  })

  update_proxy_trace <- function(output_id, data, trace_index, x, y, z = NULL) {
    payload <- list(
      x = list(data[[x]]),
      y = list(data[[y]]),
      key = list(data$row_id),
      text = list(data$tooltip)
    )

    if (!is.null(z)) {
      payload$z <- list(data[[z]])
    }

    plotlyProxy(output_id, session) |>
      plotlyProxyInvoke("restyle", payload, list(trace_index))
  }

  update_highlights <- function() {
    result <- results()
    req(result)

    id <- selected_id()
    selected <- integer()

    if (!is.null(id) && length(id) > 0 && !is.na(id) && is.finite(id)) {
      selected <- as.integer(id)
    }

    neighbors <- neighbor_ids()

    purrr::walk(names(result$projections), function(name) {
      neighbor_data <- projection_highlight_data(
        result$projections[[name]],
        result$metadata,
        neighbors
      )

      selected_data <- projection_highlight_data(
        result$projections[[name]],
        result$metadata,
        selected
      )

      update_proxy_trace(
        output_id = paste0(name, "_plot"),
        data = neighbor_data,
        trace_index = 1,
        x = "axis_1",
        y = "axis_2"
      )

      update_proxy_trace(
        output_id = paste0(name, "_plot"),
        data = selected_data,
        trace_index = 2,
        x = "axis_1",
        y = "axis_2"
      )
    })

    if (ncol(result$observed) <= 3) {
      neighbor_data <- observed_highlight_data(result$observed, result$metadata, neighbors)
      selected_data <- observed_highlight_data(result$observed, result$metadata, selected)
      z <- if (ncol(result$observed) == 3) "x3" else NULL

      update_proxy_trace("observed_plot", neighbor_data, 1, "x1", "x2", z)
      update_proxy_trace("observed_plot", selected_data, 2, "x1", "x2", z)
    }
  }

  observe({
    update_highlights()
  })

  observeEvent(input$show_observed, {
    showModal(
      modalDialog(
        title = "Observed data",
        uiOutput("observed_body"),
        size = "xl",
        easyClose = TRUE,
        footer = modalButton("Close")
      )
    )

    session$onFlushed(function() update_highlights(), once = TRUE)
  })

  output$observed_body <- renderUI({
    result <- results()
    req(result)

    dimensions <- ncol(result$observed)

    if (dimensions <= 3) {
      plotlyOutput("observed_plot", height = "70vh")
    } else {
      tagList(
        tags$small(
          class = "text-muted",
          "Showing the selected observation and its observed-space neighbors. If nothing is selected, the first rows are shown."
        ),
        tableOutput("observed_table")
      )
    }
  })

  output$observed_plot <- renderPlotly({
    result <- results()
    req(result)

    observed_plot(
      x = result$observed,
      metadata = result$metadata
    )
  })

  output$observed_table <- renderTable({
    result <- results()
    req(result)

    observed_table(
      x = result$observed,
      metadata = result$metadata,
      selected_id = selected_id(),
      neighbor_ids = neighbor_ids()
    )
  }, striped = TRUE, spacing = "s")

  output$pca_plot <- renderPlotly({
    result <- results()
    req(result)

    projection_plot(
      coordinates = result$projections$pca,
      metadata = result$metadata,
      source = "pca"
    )
  })

  output$isomap_plot <- renderPlotly({
    result <- results()
    req(result)

    projection_plot(
      coordinates = result$projections$isomap,
      metadata = result$metadata,
      source = "isomap"
    )
  })

  output$tsne_plot <- renderPlotly({
    result <- results()
    req(result)

    projection_plot(
      coordinates = result$projections$tsne,
      metadata = result$metadata,
      source = "tsne"
    )
  })

  output$umap_plot <- renderPlotly({
    result <- results()
    req(result)

    projection_plot(
      coordinates = result$projections$umap,
      metadata = result$metadata,
      source = "umap"
    )
  })
}

shinyApp(ui, server)

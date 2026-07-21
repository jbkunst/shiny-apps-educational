# packages ----------------------------------------------------------------
library(shiny)
library(bslib)
library(ggplot2)
library(tibble)

# theme options -----------------------------------------------------------
thematic::thematic_shiny(font = "auto")

apptheme <- bs_theme()

sidebar <- purrr::partial(bslib::sidebar, width = 300)
card <- purrr::partial(bslib::card, full_screen = TRUE)

# app options -------------------------------------------------------------
mean_choices <- c("-4", "-3", "-2", "-1", "-0.5", "0", "0.5", "1", "2", "3")
sd_choices <- c("0.5", "1", "1.5", "2")
n_choices <- c("100", "500", "1000", "5000")
proportion_choices <- as.character(seq(5, 95, by = 5))

class_palette <- c(
  "Negative" = "#d98f8f",
  "Positive" = "#8f95d9"
)

# helpers -----------------------------------------------------------------
safe_divide <- function(x, y) {
  if (y == 0) return(NA_real_)
  x / y
}

# development input -------------------------------------------------------
# input <- list(mean_1 = "-1", sd_1 = "1", mean_2 = "1", sd_2 = "1", threshold = 0, n = "500", p_1 = "50")

# ui ----------------------------------------------------------------------
ui <- page_fillable(
  theme = apptheme,
  padding = 0,
  layout_sidebar(
    fillable = TRUE,
    sidebar = sidebar(
      title = "ROC Curve",

      tags$small("Negative distribution"),
      layout_columns(
        col_widths = c(6, 6),
        shinyWidgets::sliderTextInput(
          "mean_1",
          tags$small("Mean"),
          choices = mean_choices,
          selected = "-1",
          grid = FALSE,
          hide_min_max = TRUE,
        dragRange = FALSE
        ),
        shinyWidgets::sliderTextInput(
          "sd_1",
          tags$small("SD"),
          choices = sd_choices,
          selected = "1",
          grid = FALSE,
          hide_min_max = TRUE,
        dragRange = FALSE
        )
      ),

      tags$small("Positive distribution"),
      layout_columns(
        col_widths = c(6, 6),
        shinyWidgets::sliderTextInput(
          "mean_2",
          tags$small("Mean"),
          choices = mean_choices,
          selected = "1",
          grid = FALSE,
          hide_min_max = TRUE,
        dragRange = FALSE
        ),
        shinyWidgets::sliderTextInput(
          "sd_2",
          tags$small("SD"),
          choices = sd_choices,
          selected = "1",
          grid = FALSE,
          hide_min_max = TRUE,
        dragRange = FALSE
        )
      ),

      sliderInput(
        "threshold",
        tags$small("Threshold"),
        min = -5,
        max = 5,
        value = 0,
        step = 0.05,
        ticks = FALSE
      ),

      shinyWidgets::sliderTextInput(
        "n",
        tags$small("Number of observations"),
        choices = n_choices,
        selected = "1000",
        grid = FALSE,
        hide_min_max = TRUE,
        dragRange = FALSE
      ),

      shinyWidgets::sliderTextInput(
        "p_1",
        tags$small("Negative proportion"),
        choices = proportion_choices,
        selected = "50",
        grid = FALSE,
        hide_min_max = TRUE,
        dragRange = FALSE,
        post = "%"
      )
    ),
    layout_columns(
      col_widths = c(6, 6, 12),
      row_heights = c(1, 0.72),
      card(
        card_header("Score distributions"),
        card_body(plotOutput("distribution_plot", height = "100%"))
      ),
      card(
        card_header("ROC curve"),
        card_body(plotOutput("roc_plot", height = "100%"))
      ),
      card(
        card_header("Metrics at threshold"),
        card_body(tableOutput("metrics_table"))
      )
    )
  )
)

# server ------------------------------------------------------------------
server <- function(input, output, session) {
  data_sample <- reactive({
    set.seed(1)

    n <- as.integer(input$n[[1]])
    p_1 <- as.numeric(input$p_1[[1]]) / 100
    mean_1 <- as.numeric(input$mean_1[[1]])
    mean_2 <- as.numeric(input$mean_2[[1]])
    sd_1 <- as.numeric(input$sd_1[[1]])
    sd_2 <- as.numeric(input$sd_2[[1]])

    n_1 <- round(n * p_1)
    n_2 <- n - n_1

    tibble(
      score = c(
        rnorm(n_1, mean_1, sd_1),
        rnorm(n_2, mean_2, sd_2)
      ),
      observed = factor(
        c(rep("Negative", n_1), rep("Positive", n_2)),
        levels = names(class_palette)
      )
    )
  })

  density_data <- reactive({
    mean_1 <- as.numeric(input$mean_1[[1]])
    mean_2 <- as.numeric(input$mean_2[[1]])
    sd_1 <- as.numeric(input$sd_1[[1]])
    sd_2 <- as.numeric(input$sd_2[[1]])
    p_1 <- as.numeric(input$p_1[[1]]) / 100

    score_grid <- seq(
      min(mean_1 - 4 * sd_1, mean_2 - 4 * sd_2),
      max(mean_1 + 4 * sd_1, mean_2 + 4 * sd_2),
      length.out = 500
    )

    densities <- tibble(
      score = rep(score_grid, 2),
      observed = factor(rep(names(class_palette), each = length(score_grid)), levels = names(class_palette))
    )

    densities$density <- ifelse(
      densities$observed == "Negative",
      dnorm(densities$score, mean_1, sd_1) * p_1,
      dnorm(densities$score, mean_2, sd_2) * (1 - p_1)
    )

    densities
  })

  roc_data <- reactive({
    mean_1 <- as.numeric(input$mean_1[[1]])
    mean_2 <- as.numeric(input$mean_2[[1]])
    sd_1 <- as.numeric(input$sd_1[[1]])
    sd_2 <- as.numeric(input$sd_2[[1]])

    threshold <- seq(
      max(mean_1 + 5 * sd_1, mean_2 + 5 * sd_2),
      min(mean_1 - 5 * sd_1, mean_2 - 5 * sd_2),
      length.out = 500
    )

    tibble(
      threshold = threshold,
      fpr = 1 - pnorm(threshold, mean_1, sd_1),
      tpr = 1 - pnorm(threshold, mean_2, sd_2)
    )
  })

  metrics <- reactive({
    data <- data_sample()
    predicted_positive <- data$score >= input$threshold
    observed_positive <- data$observed == "Positive"

    tp <- sum(predicted_positive & observed_positive)
    fp <- sum(predicted_positive & !observed_positive)
    tn <- sum(!predicted_positive & !observed_positive)
    fn <- sum(!predicted_positive & observed_positive)

    tpr <- safe_divide(tp, tp + fn)
    fpr <- safe_divide(fp, fp + tn)
    precision <- safe_divide(tp, tp + fp)
    accuracy <- safe_divide(tp + tn, tp + tn + fp + fn)
    specificity <- safe_divide(tn, tn + fp)
    f1 <- safe_divide(2 * precision * tpr, precision + tpr)
    mean_1 <- as.numeric(input$mean_1[[1]])
    mean_2 <- as.numeric(input$mean_2[[1]])
    sd_1 <- as.numeric(input$sd_1[[1]])
    sd_2 <- as.numeric(input$sd_2[[1]])
    auc <- pnorm((mean_2 - mean_1) / sqrt(sd_1^2 + sd_2^2))

    tibble(
      metric = c(
        "True positive rate",
        "False positive rate",
        "Specificity",
        "Precision",
        "F1 score",
        "Accuracy",
        "AUC"
      ),
      value = c(tpr, fpr, specificity, precision, f1, accuracy, auc)
    )
  })

  output$distribution_plot <- renderPlot({
    density <- density_data()
    points <- data_sample()
    points <- points[seq_len(min(nrow(points), 200)), , drop = FALSE]

    ggplot(density, aes(score, density, color = observed, fill = observed)) +
      geom_area(alpha = 0.24, linewidth = 0) +
      geom_line(linewidth = 1.1) +
      geom_point(
        data = points,
        aes(x = score, y = 0, color = observed),
        inherit.aes = FALSE,
        position = position_jitter(height = max(density$density) * 0.025),
        alpha = 0.45,
        size = 1.4
      ) +
      geom_vline(xintercept = input$threshold, linewidth = 1, linetype = "dashed") +
      scale_color_manual(values = class_palette) +
      scale_fill_manual(values = class_palette) +
      coord_cartesian(ylim = c(-max(density$density) * 0.05, max(density$density) * 1.05)) +
      labs(x = "Score", y = "Weighted density", color = NULL, fill = NULL) +
      theme_minimal(base_size = 13) +
      theme(legend.position = "bottom")
  }, res = 96)

  output$roc_plot <- renderPlot({
    roc <- roc_data()
    current <- metrics()

    current_fpr <- current$value[current$metric == "False positive rate"]
    current_tpr <- current$value[current$metric == "True positive rate"]

    ggplot(roc, aes(fpr, tpr)) +
      geom_abline(slope = 1, intercept = 0, linetype = "dotted", color = "grey60") +
      geom_path(color = "#4f56b3", linewidth = 1.2) +
      annotate("point", x = current_fpr, y = current_tpr, color = "#d24b4b", size = 3.5) +
      coord_equal(xlim = c(0, 1), ylim = c(0, 1), expand = FALSE) +
      labs(x = "False positive rate", y = "True positive rate") +
      theme_minimal(base_size = 13)
  }, res = 96)

  output$metrics_table <- renderTable({
    data <- metrics()
    data$value <- ifelse(is.na(data$value), NA_character_, sprintf("%.3f", data$value))
    data
  }, striped = TRUE, bordered = FALSE, spacing = "s")
}

shinyApp(ui, server)

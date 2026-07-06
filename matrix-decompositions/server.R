# input <- list(
#   nrows = sample(2:5, 1),
#   decomposition = sample(c("svd", "eigen", "spectral", "pca", "qr", "lu", "cholesky"), 1),
#   matrix_kind = sample(c("dense_spd", "sparse_spd", "banded_spd", "diagonal_spd"), 1),
#   coefficient_max = sample(1:6, 1),
#   generate_matrix = 0
# )

# matrix_settings <- list(
#   n = input$nrows,
#   kind = input$matrix_kind,
#   coefficient_max = input$coefficient_max
# )

# matrixA <- generate_spd_matrix(
#   n = settings$n,
#   kind = settings$kind,
#   coefficient_max = settings$coefficient_max
# )

# matrixA

function(input, output, session) {

  matrixA <- reactiveVal()

  matrix_settings <- reactive({

    req(input$nrows, input$matrix_kind, input$coefficient_max)

    matrix_settings <- list(
      n = input$nrows,
      kind = input$matrix_kind,
      coefficient_max = input$coefficient_max
    )

    matrix_settings

  })

  observeEvent(matrix_settings(), {

    settings <- matrix_settings()

    matrixA(
      generate_spd_matrix(
        n = settings$n,
        kind = settings$kind,
        coefficient_max = settings$coefficient_max
      )
    )

  }, ignoreInit = FALSE)

  observeEvent(input$generate_matrix, {

    settings <- matrix_settings()

    matrixA(
      generate_spd_matrix(
        n = settings$n,
        kind = settings$kind,
        coefficient_max = settings$coefficient_max
      )
    )

  }, ignoreInit = TRUE)

  output$matrix_render <- renderUI({

    matrixA <- matrixA()
    req(matrixA)

    tagList(
      withMathJax(),
      str_c("$$ A = ", matrix2latex(matrixA), "$$")
    )

  })

  output$decomposition_output <- renderUI({

    matrixA <- matrixA()
    req(matrixA, input$decomposition)

    file <- here(str_c("rmd/", input$decomposition, ".Rmd"))

    rendered <- tryCatch(
      {
        output_dir <- tempfile("matrix-decomposition-")
        dir.create(output_dir)
        on.exit(unlink(output_dir, recursive = TRUE), add = TRUE)

        rendered_file <- rmarkdown::render(
          input = file,
          output_format = "html_fragment",
          output_file = "decomposition.html",
          output_dir = output_dir,
          intermediates_dir = output_dir,
          quiet = TRUE,
          params = list(mat = matrixA)
        )

        readLines(
          rendered_file,
          encoding = "UTF-8"
        )
      },
      error = function(e) {
        tags$div(
          class = "text-warning",
          tags$strong("Cannot compute this decomposition."),
          tags$p(conditionMessage(e))
        )
      }
    )

    if (inherits(rendered, "shiny.tag")) {
      rendered
    } else {
      withMathJax(HTML(rendered))
    }

  })

}

page_sidebar(
  title  = tags$h4("MATRIX DECOMPOSITIONS", class = "title"),
  theme = theme_matrix,
  fluid = TRUE,
  sidebar = sidebar(
    width = 350,
    withMathJax(),
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
    ),
    tags$style(HTML(".selectize-dropdown-content{max-height:none!important;overflow-y:visible!important;}")),
    selectInput(
      "decomposition",
      tags$strong("Decomposition"),
      choices = list(
        "SVD" = "svd",
        "Eigen"  = "eigen",
        "Spectral" = "spectral",
        "PCA" = "pca",
        "\\(QR\\)" = "qr",
        "\\(LU\\)" = "lu",
        "Cholesky" = "cholesky"
      )
    ),
    sliderInput(
      "nrows",
      label = tags$strong("Number of rows and cols"),
      min = 2,
      max = 5,
      value = 3
    ),
    selectInput(
      "matrix_kind",
      label = label_with_info(
        "Matrix structure",
        "Controls the shape of the generated matrix: dense, sparse, banded, or diagonal. All options are symmetric positive-definite."
      ),
      choices = list(
        "Dense" = "dense_spd",
        "Sparse" = "sparse_spd",
        "Banded" = "banded_spd",
        "Diagonal" = "diagonal_spd"
      )
    ),
    sliderInput(
      "coefficient_max",
      label = label_with_info(
        "Max absolute value",
        "Sets the largest absolute value used for random integer coefficients. The diagonal is adjusted automatically so the matrix stays positive-definite."
      ),
      min = 1,
      max = 6,
      value = 4,
      step = 1
    ),
    actionButton(
      "generate_matrix",
      tagList(icon("shuffle"), "Generate new matrix"),
      class = "btn-primary"
    ),
    htmlOutput("matrix_render"),
    accordion(
      open = FALSE,
      accordion_panel(
        "How it works",
        tags$small(htmltools::includeMarkdown("readme.md"))
      ),
      accordion_panel(
        "Inspiration",
        tags$p(
          "This idea came from the @kareem_carr ",
          tags$a(
            "tweet",
            href = "https://twitter.com/kareem_carr/status/1475255675718709250",
            target = "_blank"
          ),
          "."
        ),
        tags$img(
          src = "matrix.jpg",
          class = "inspiration-image"
        )
      )
    ),
    tags$small(htmltools::includeMarkdown("credits.md"))
  ),
  htmlOutput("decomposition_output")
)

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
    radioButtons(
      "decomposition",
      tags$strong("Decomposition"),
      choices = list(
        "SVD" = "svd",
        "Eigen"  = "eigen",
        "\\(QR\\)" = "qr",
        "\\(LU\\)" = "lu",
        "Cholesky" = "cholesky"
      )
    ),
    textAreaInput(
      "matrix",
      label = tags$strong("Matrix values"),
      rows = 4,
      # value = "1, 2,3,\n2, 4.5, 6,\n3, 3, 3"
      value = "4, 12, -16, 12, 37, -43, -16, -43, 98"
      # value = "1, 2\n2, 1"
    ),
    sliderInput(
      "nrows",
      label = tags$strong("Number of rows and cols"),
      min = 2,
      max = 5,
      value = 3
    ),
    htmlOutput("matrix_render"),
    tags$small(
      "Some decompositions do not require a square matrix,
                 in this app we will use square real value matrix for simplicity"
    ),
    includeMarkdown("readme.md")
  ),
  htmlOutput("decomposition_output")
)
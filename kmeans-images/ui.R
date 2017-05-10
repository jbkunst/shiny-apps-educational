fluidPage(
  theme = shinytheme("cosmo"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
    ),
  # Tilte
  fluidRow(column(6, offset = 0, includeMarkdown("mds/intro.md"))),
  hr(),
  # Inputs
  fluidRow(
    column(4, selectizeInput("image", "Image", choices = img_choices, width = "100%")),
    column(4, sliderInput("k1", "K for colors", min = 2, max = 10, value = 5, width = "100%")),
    column(4, sliderInput("k2", "K for colors and $x, y$", min = 100, max = 1000, value = 500, step = 50, width = "100%"))
    ),
  # Outputs
  fluidRow(
    column(4, h5("Orignal image"), plotOutput("originalImage")),
    column(4, h5("Cluster using only colors"), plotOutput("resultImage1")),
    column(4, h5("Cluster using colors and position"), plotOutput("resultImage2"))
      ),
  #   column(
  #     width = 6,
  #     h4("Orignal colors distribution, top 10"),
  #     plotOutput("originaltDist")
  #     ),
  #   column(
  #     width = 6,
  #     h4("Cluster colors distribution"),
  #     plotOutput("resultDist")
  #     ),
  #   column(
  #     width = 6,
  #     h4("Scatterplot pixels sample"),
  #     scatterplotThreeOutput("scatterplot3d")
  #     ),
  #   column(
  #     width = 6,
  #     h4("Scatterplot clusters"),
  #     scatterplotThreeOutput("scatterplot3dresult")
  #     )
  #   ),
  hr(),
  fluidRow(
    column(
      width = 6,
      offset = 6,
      class = "text-right",
      includeMarkdown("mds/about.md")
      )
    )
  )

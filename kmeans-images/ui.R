fluidPage(
  theme = shinytheme("cosmo"),
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
    ),
  fluidRow(
    column(12, includeMarkdown("mds/intro.md")),
    column(4, selectizeInput("image", "Image", choices = img_choices, width = "100%")),
    column(4, sliderInput("k1", "K for colors", min = 2, max = 10, value = 5, width = "100%")),
    column(4, sliderInput("k2", "K for colors and position", min = 100, max = 1000, value = 500, step = 50, width = "100%"))
    ),
  # K means
  fluidRow(
    column(4, h5("Orignal image"), plotOutput("originalImage")),
    column(4, h5("Cluster using only colors"), plotOutput("resultImage1")),
    column(4, h5("Cluster using colors and position"), plotOutput("resultImage2"))
    ),
  fluidRow(
    column(4, h5("filter")),
    column(4, h5("Gray Scale"), imageOutput("grayImage")),
    column(4, h5("Filter Image"), plotOutput("filterImage"))
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
  fluidRow(column(width = 4, offset = 8, class = "text-right", includeMarkdown("mds/about.md")))
  )

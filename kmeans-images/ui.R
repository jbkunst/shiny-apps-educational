shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "css/bootstrap.cosmo.min.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
    ),
    # Tilte
    fluidRow(
      column(width = 6, offset = 0,
             includeMarkdown("mds/intro.md")
      )
    ),
    hr(),
    # Inputs
    fluidRow(
      column(width = 6,
             selectizeInput("image", NULL, choices = img_choices, width = "100%")
             ),
      column(width = 6,
             sliderInput("k", NULL, min = 2, max = 10, value = 5, width = "100%")
             )
      ),
    # Outputs
    fluidRow(
      column(width = 6,
             h4("Orignal image"),
             plotOutput("originalImage")
             ),
      column(width = 6,
             h4("Cluster colors image"),
             plotOutput("resultImage")
             ),
      column(width = 6,
             h4("Orignal colors distribution, top 10"),
             plotOutput("originaltDist")
             ),
      column(width = 6,
             h4("Cluster colors distribution"),
             plotOutput("resultDist")
             ),
      column(width = 6,
             h4("Scatterplot pixels sample"),
             scatterplotThreeOutput("scatterplot3d")
             ),
      column(width = 6,
             h4("Scatterplot clusters"),
             scatterplotThreeOutput("scatterplot3dresult")
             )
      ),
    hr(),
    fluidRow(
      column(width = 6, offset = 6, class = "text-right",
             includeMarkdown("mds/about.md")
             )
      )
    )
  )
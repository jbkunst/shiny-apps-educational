shinyUI(
  fluidPage(
    tags$link(rel = "stylesheet", type = "text/css", href = "https://bootswatch.com/paper/bootstrap.css"),
    tags$br(),
    fluidRow(
      column(width = 3,
             selectInput("url", label = "URL:", choices = names(corpus_data), selectize = FALSE),
             sliderInput("n_words", label = "Number of words:", min = 10, max = 500, step = 10, value = 150),
             selectInput("scale", label = "Scale:", choices = c("linear", "log", "sqrt"), , selectize = FALSE),
             selectInput("spiral", label = "Spiral:", choices = c("archimedean", "rectangular"), selectize = FALSE),
             selectInput("font", label = "Font:", choices = choices_font, , selectize = FALSE),
             sliderInput("font_weight", label = "Font Weight:", min = 100, max = 900, value = 400, step = 100),
             sliderInput("padding", label = "Padding:", min = 0, max = 5, value = 0, step = 1),
             sliderInput("rotate", label = "Rotate:", min = -90, max = 90, value = c(-30, 30), step = 10)
      ),
      column(width = 9,
             d3wordcloudOutput("d3wc"),
             p(class = "pull-right small",
               "Code by ", a(href = "http://jkunst.com", "Joshua Kunst", target = "_blank"),
               " | Package ", a(href = "https://github.com/jbkunst/d3wordcloud", "d3wordcloud", target = "_blank"),
               " | Repo here ",
               a(href = "https://github.com/jbkunst/shiny-apps/tree/master/d3wordcloud", icon("github"), target = "_blank")
               )
             )
      )
    )
  )
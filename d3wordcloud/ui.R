shinyUI(
  fluidPage(
    tags$link(rel = "stylesheet", type = "text/css", href = "https://bootswatch.com/paper/bootstrap.css"),
    fluidRow(
      column(width = 3, class = "panel",
             selectInput("url", label = "URL:", choices = names(corpus_data), selectize = FALSE),
             sliderInput("n_words", label = "Number of words:", min = 10, max = 500, step = 10, value = 150),
             selectInput("size_scale", label = "Size Scale:",
                         choices = c("linear", "log", "sqrt"), selectize = FALSE),
             selectInput("spiral", label = "Spiral:", choices = c("archimedean", "rectangular"), selectize = FALSE),
             selectInput("font", label = "Font:", choices = choices_font, selectize = FALSE),
             sliderInput("padding", label = "Padding:", min = 0, max = 5, value = 0, step = 1),
             sliderInput("rotate", label = "Rotate:", min = -90, max = 90, value = c(-30, 30), step = 10),
             selectInput("color_type", label = "Color Type*", choices = c("gradient", "a color by word")),
             selectInput("color_scale", label = "Color Scale**:",
                         choices = c("linear", "log", "sqrt"), selectize = FALSE),
             selectInput("colors", label = "Colors:", choices = colors,
                         multiple = TRUE, selected = sample(colors, size = 2), selectize = TRUE)
      ),
      column(width = 9,
             d3wordcloudOutput("d3wc"),
             p(class = "pull-right small text-right",
               icon("code"), " by ", a(href = "http://jkunst.com", "Joshua Kunst", target = "_blank"),
               " | Package ", a(href = "https://github.com/jbkunst/d3wordcloud",
                                "d3wordcloud", target = "_blank"),
               " | Repo here ",
               a(href = "https://github.com/jbkunst/shiny-apps/tree/master/d3wordcloud",
                 icon("github"), target = "_blank"),
               br(),
               "* See details ", tags$a("here", href = "http://rpubs.com/jbkunst/100416", target = "_blank"),
               br(),
               "** Only when color type is gradient"
               )
             )
      )
    )
  )
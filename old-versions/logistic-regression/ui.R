fixedPage(
  theme = theme,
  h3("Logistic Regression"),
  sidebarLayout(
    sidebarPanel(
      width = 3,
      withMathJax(),
      radioButtons(
        "relationship",
        tags$strong("Relationship"),
        choices = list(
          "\\(x > y\\)" = "x > y", 
          "\\(x^2 > y\\)" = "x^2 - y > 0",
          "\\(|x| > |y|\\)" = "abs(x) - abs(y) > 0",
          "\\(x^2 + y^2 < 0.5\\)" = "x^2 + y^2 < 0.5",
          "\\( \\sin(x \\cdot \\pi ) > \\sin(y \\cdot \\pi ) \\)" = "sin(x*pi) > sin(y*pi)"
          )
        ),
      sliderInput(
        "percent_noise",
        tags$strong("Percent noise"),
        min = 0,
        max = 50,
        step = 5,
        value = 20,
        post = "%",
        animate = TRUE
        ),
      sliderInput(
        "order",
        tags$strong("Order"),
        min = 1,
        max = 4,
        # ticks = FALSE,
        step = 1,
        value = 1
      ),
      sliderInput(
        "n",
        tags$strong("Number of observartions"),
        min = 100,
        max = 1000,
        step = 100,
        value = 500
        )
      ),
      mainPanel(
        width = 9,
        tabsetPanel(
          type = "pills",
          tabPanel("Field", plotOutput("predfield")),
          tabPanel("Marginals", plotOutput("marginals")),
          tabPanel("ROC curve", plotOutput("roccurve")),
          tabPanel("Densities", plotOutput("densities")),
          tabPanel("Model", align = "center", tableOutput("model")),
          tabPanel("About",)
          ),
        )
    )
  )

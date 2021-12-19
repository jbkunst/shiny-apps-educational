fluidPage(
  theme = theme_chess,
  useShinyjs(),
  fluidRow(
    column(
      width = 8,
      offset = 2,
      h2(id = "title", class = "text-center", "Chess Explorer"),
      tags$br(),
      tabsetPanel(
        type = "pills",
        tabPanel(
          HTML("&#9819; Openings"),
          fluidRow(
            column(4, selectInput("opening", label = "Opening", width = "100%", choices = unique(chessopenings$name))),
            column(8, selectInput("variation", label = "Variantion", width = "100%", choices = NULL ))
            ),
          fluidRow(
            column(width = 6, offset = 3, chessboardjsOutput("board_opening"))
            )
          ),
        tabPanel(
          HTML("&#9820; Database"),
          fluidRow(
            column(width = 6, offset = 3, dataTableOutput("table_openings"))
            )
          ),
        tabPanel(
          HTML("&#9818; About"),
          fluidRow(
            column(width = 6, offset = 3, includeMarkdown("Readme.md"))
            )
          )
        )
      )
    )
  )

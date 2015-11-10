shinyUI(
  fluidPage(
    tags$head(
      tags$link(rel = "stylesheet", type = "text/css", href = "https://bootswatch.com/paper/bootstrap.min.css"),
      tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css")
      ),
    fluidRow(
      column(12,
             h2(id = "title", class = "text-center", "Chess Explorer"),
             tags$br(),
             tabsetPanel(type = "pills",
                         tabPanel(HTML("&#9819; Openings"),
                                  fluidRow(
                                    column(3, offset = 1, selectInput("opening", label = "Opening", width = "100%",
                                                          choices = unique(chessopenings$name))),
                                    column(8, selectInput("variation", label = "Variantion", width = "100%",
                                                          choices = NULL))
                                    ),
                                  fluidRow(
                                    column(3, offset = 1, chessboardjsOutput("board_opening"))
                                  )
                                  ),
                         tabPanel(HTML("&#9820; Database"), "hola"),
                         tabPanel(HTML("&#9822; Board"), "hello"),
                         tabPanel(HTML("&#9818; About"), "olé")
                         )
             )
      )
    )
  )

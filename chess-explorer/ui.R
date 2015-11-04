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
                         tabPanel(HTML("&#9819; Openings"), "holo"),
                         tabPanel(HTML("&#9820; Database"), "hola"),
                         tabPanel(HTML("&#9822; Board"), "hello"),
                         tabPanel(HTML("&#9818; About"), "olé")
                         )
             )
      )
    )
  )

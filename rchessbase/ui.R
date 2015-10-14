dashboardPage(
  skin = "black",
  dashboardHeader(),
  dashboardSidebar(),
  dashboardBody(
    fluidRow(
      column(
        width = 4,
        box(
          width = 12,
          chessboardjsOutput("board", height = "100%")
          )
        ),
      column(
        width = 8,
        box(width = 4, chessboardjsOutput("board1",  height = "100%")),
        box(width = 4, chessboardjsOutput("board2",  height = "100%")),
        box(width = 4, chessboardjsOutput("board3",  height = "100%")),
        box(width = 4, chessboardjsOutput("board4",  height = "100%")),
        box(width = 4, chessboardjsOutput("board5",  height = "100%")),
        box(width = 4, chessboardjsOutput("board6",  height = "100%"))
        )
      )
    )
  )
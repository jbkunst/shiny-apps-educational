shinyServer(function(input, output) {
  
  output$tbl <- DT::renderDataTable({
    head(games, 10) %>% select(-moves)
  }, options = list(lengthChange = FALSE))
  
  
  output$board <- renderChessboardjs({chessboardjs()})
  output$board1 <- renderChessboardjs({chessboardjs()})
  output$board2 <- renderChessboardjs({chessboardjs()})
  output$board3 <- renderChessboardjs({chessboardjs()})
  output$board4 <- renderChessboardjs({chessboardjs()})
  output$board5 <- renderChessboardjs({chessboardjs()})
  output$board6 <- renderChessboardjs({chessboardjs()})

})
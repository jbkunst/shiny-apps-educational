# input <- list(opening = "Bird's Opening", variation = ") 

shinyServer(function(input, output, clientData, session) {
  
  shinyjs::runjs('toggleCodePosition();')
  
  observe({
    op <- input$opening
    var <- chessopenings %>% filter(name == op) %>% .$variant
    updateSelectInput(session, "variation", choices = var)
    
  })
  
  output$board_opening <- renderChessboardjs({
    
    pgn <- chessopenings %>%
      filter(variant == input$variation) %>%
      .$pgn
    
    chss <- Chess$new()
    chss$load_pgn(pgn)
    fen <- chss$fen()
    chessboardjs(fen)
    })
  
  output$table_openings <- renderDataTable(chessopenings)

})

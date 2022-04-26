# input <- list(
#   matrix = "1,2,3,2,4,6,3,3,3",
#   nrows = 3,
#   decomposition = "qr"
# )

shinyServer(function(input, output) {

  vector <- reactive({
    
    vector <- input$matrix %>% 
      str_split("\\,") %>% 
      unlist() %>% 
      as.numeric()
    
    vector
    
  })
  
  matrixA <- reactive({
    
    vector <- vector()
    
    matrixA <- matrix(
      vector, 
      nrow = input$nrows, 
      ncol = input$nrows, 
      byrow = TRUE
      )
    
    matrixA
    
  })
  
  output$matrix_render <- renderUI({
    
    vector  <- vector()
    matrixA <- matrixA()
    
    warning_msg <- NULL
    
    if(length(vector)%%input$nrows != 0) {
      
      warning_msg <- str_glue(
        "Data length {length(vector)} is not a sub-multiple or multiple of the number of rows {input$nrows}. Recycling vector elements."
      )

    } else if ( length(vector) < input$nrows**2 ) {
      
      warning_msg <- str_glue(
        "Only first {input$nrows**2} given values will be used."
      )
      
    }
    
    tagList(
      withMathJax(),
      str_c("$$ A = ", matrix2latex(matrixA), "$$"),
      if(!is.null(warning_msg)) tags$small(tags$i(class = "text-warning", warning_msg))
    )
    
  })  
  
  output$decomposition_output <- renderUI({
    
    matrixA <- matrixA()
    
    file <- here(str_c("rmd/", input$decomposition, ".Rmd"))
    
    withMathJax(
      HTML(
        readLines(
          rmarkdown::render(
            input = file,
            output_format = "html_fragment",
            output_file = "temp.html",
            quiet = TRUE,
            params = list(mat = matrixA)
            ),
          encoding = "UTF-8"
          )
        )
      )
    
    
  })

})

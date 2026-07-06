# input <- list(
#   matrix = "1,2,3,2,4,6,3,3,3",
#   nrows = 3,
#   decomposition = "qr"
# )

shinyServer(function(input, output) {

  vector <- reactive({
    
    raw_values <- input$matrix %>% 
      str_split("\\,") %>% 
      unlist() %>% 
      str_trim()
    
    vector <- suppressWarnings(as.numeric(raw_values))
    
    validate(
      need(length(raw_values) > 0 && all(nzchar(raw_values)), "Please provide numeric matrix values separated by commas."),
      need(!anyNA(vector), "Matrix values must be numeric and separated by commas.")
    )
    
    vector
    
  })
  
  matrixA <- reactive({
    
    vector <- vector()
    expected_length <- input$nrows^2
    
    validate(
      need(
        length(vector) == expected_length,
        str_glue("Please provide exactly {expected_length} values for a {input$nrows} x {input$nrows} matrix.")
      )
    )
    
    matrixA <- matrix(
      vector, 
      nrow = input$nrows, 
      ncol = input$nrows, 
      byrow = TRUE
      )
    
    matrixA
    
  })
  
  output$matrix_render <- renderUI({
    
    matrixA <- matrixA()
    
    tagList(
      withMathJax(),
      str_c("$$ A = ", matrix2latex(matrixA), "$$")
    )
    
  })  
  
  output$decomposition_output <- renderUI({
    
    matrixA <- matrixA()
    
    file <- here(str_c("rmd/", input$decomposition, ".Rmd"))
    
    message(file)
    
    rendered <- tryCatch(
      readLines(
        rmarkdown::render(
          input = file,
          output_format = "html_fragment",
          output_file = "temp.html",
          quiet = TRUE,
          params = list(mat = matrixA)
          ),
        encoding = "UTF-8"
        ),
      error = function(e) {
        tags$div(
          class = "text-warning",
          tags$strong("Cannot compute this decomposition."),
          tags$p(conditionMessage(e))
        )
      }
    )
    
    if (inherits(rendered, "shiny.tag")) {
      rendered
    } else {
      withMathJax(HTML(rendered))
    }
    
  })

})
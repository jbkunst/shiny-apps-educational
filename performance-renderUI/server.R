input <- list(package = "plotly", ncharts = 4)
function(input, output) {
  
  output$charts <- renderUI({
    
    print(reactiveValuesToList(input))
    
    chart <- charts[[input$package]]
    
    browsable(
      tagList(
        map(seq_len(input$ncharts), function(x){
          tags$div(chart, class = "col-sm-3")
        })
        )
      )
    
  })
  
}



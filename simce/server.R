require(shiny)
require(rCharts)

input <- list(g_variable = "cyl")
shinyServer(function(input, output) {

  output$plot <- renderChart2({
    
    df <- data.frame(name=c("US", "GB", "RU"), value=c(5,1,8))
    df <- df[order(df$value),]
    
    p <- Highcharts$new()
    
    p$series(data = df$value, type = "column",
             color = list(pattern = 'www/pattern_chalck.jpg', width = 160, height = 500))
    
    p$xAxis(categories = df$name)
    p$set(width = "100%", height= "100%")
    
    p
    
  })

})
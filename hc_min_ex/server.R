require(shiny)
require(rCharts)

shinyServer(function(input, output) {

  
  output$plot <- renderChart2({
    
    data(mtcars)
    theme <- 'gray.js'
    theme_url <-  sprintf('http://rawgithub.com/highslide-software/highcharts.com/master/js/themes/%s', theme)
    
    p <- hPlot(mpg ~ hp, data = mtcars, type = 'scatter', group = input$g_variable)
    p$setTemplate(afterScript = sprintf("<script src='%s'></script>", theme_url))
    p$set(width = "100%", height= "100%")
    
    return(p)
  })
})
require(shiny)
require(rCharts)

input <- list(g_variable = "cyl")
shinyServer(function(input, output) {

  output$plot <- renderChart2({
    
    df <- data.frame(name=c("US", "GB", "RU"), value=c(5,1,8))
    df <- df[order(df$value),]
    
    p <- Highcharts$new()
    
    p$series(data = df$value, type ="column")
    #     p$setTemplate(afterScript = "<script src='https://gist.githubusercontent.com/jbkunst/dce7bd627420629640db/raw/'></script>")
    #     p$setTemplate(afterScript = "<script src='https://gist.githubusercontent.com/jbkunst/6bf5ac8431db4fddd19b/raw/'></script>")
    
    p$xAxis(categories = df$name)
    p$set(width = "100%", height= "100%")

    p

    # html <- p$render()
    # cat(html)
    
  })

})
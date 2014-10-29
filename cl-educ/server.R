require(shiny)
require(rCharts)

input <- list(g_variable = "cyl")
shinyServer(function(input, output) {

  output$plot <- renderChart2({
    
    df <- data.frame(name=c(2006:2012), value=c(5,1,8,5,6,4,5))
  
    p <- Highcharts$new()
    
    p$series(name = "Colegio", data = df$value, type ="line", lineWidth = 9, color="#FFFFFF")
    
    p$series(name = "Mediana", data = df$value+rnorm(nrow(df),0,1), type = "line",
             lineWidth = 1, dashStyle="longdash", color="#FCFCFC")
    p$series(name = "1er quintil superior", data = df$value+5, type = "line",
             lineWidth = 1, dashStyle="dash", color="#ECECEC")
    p$series(name = "3er quintil superior", data = df$value-5, type = "line",
             lineWidth = 1, dashStyle="dash", color="#ECECEC")
    
    
    p$xAxis(categories = df$name)
    p$set(width = "100%", height= "100%")

    p

    # html <- p$render()
    # cat(html)
    
  })

})
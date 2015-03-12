#  server.R
library(shiny)
library(rCharts)
library(ggplot2)
library(leaflet)

data(uspop2000)
base_df <- head(uspop2000[which(uspop2000$State == "AL"), ])


shinyServer(function(input, output){
  
  output$myChart1 <- renderPlot({
    pop_plot <- ggplot(base_df, aes(x = City, y = Pop2000)) +
      geom_bar(stat = "identity")
    print(pop_plot)
  })
  
  output$myChart2 <- renderMap({
    map3 <- Leaflet$new()
    map3$setView(c(37.45, -93.85), zoom = 5)
    map3$marker(c(37.45, -93.85), bindPopup = "Hi. I am a popup")
    map3$marker(c(37.45, -93.85), bindPopup = "Hi. I am another popup")
    map3$set(dom = 'myChart2')
    map3
  })
})
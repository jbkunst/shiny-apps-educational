shinyServer(function(input, output) {
  
  output$map <- renderLeaflet({
    data <- data_frame( a = 5)
    m <- data %>%
      leaflet() %>%
      tileOptions(continuousWorld = FALSE) %>% 
      addTiles("http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png") %>% 
      setView(0, 0, input$zoom)
    
    m

    
  })

})

leaflet::tileOptions()
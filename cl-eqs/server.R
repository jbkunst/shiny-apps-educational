shinyServer(function(input, output){

  output$map <- renderLeaflet({

    data <- data %>% 
      mutate(size = Magnitud^8,
             opacity = size/(max(size)*2)) %>% 
      filter(between(Magnitud, input$fmagnitud[1], input$fmagnitud[2]))
    
    
    m <- leaflet(data) %>%
      addTiles() %>% 
      addCircles(lng = ~Longitud, lat = ~Latitud, radius = ~ size, opacity = ~opacity) %>%
      addMarkers(lng = ~Longitud, lat = ~Latitud, popup = ~ Magnitud)
      
    m
    
  })
  
  output$table <- renderDataTable({
    
    data
    
  }, options = list(pageLength = 5, lengthChange = FALSE, searching = FALSE, info = FALSE, language = list(url = "json/Spanish.json")))
  
})
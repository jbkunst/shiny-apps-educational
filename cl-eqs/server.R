shinyServer(function(input, output){

  output$map <- renderLeaflet({

    data <- data %>% 
      mutate(size = (extract_numeric(Magnitud))^8,
             opacity = size/(max(size)*2),
             info = paste("Magnitud: ", Magnitud))
    
    
    m <- leaflet(data) %>%
      addTiles() %>% 
      addCircles(lng = ~Longitud, lat = ~Latitud, radius = ~ size, opacity = ~opacity) %>%
      addMarkers(lng = ~Longitud, lat = ~Latitud, popup = ~ info)
      
    m
    
  })
  
  output$table <- renderDataTable({
    
    if(input$showmoretable){
      data
    } else {
      data[, c("Fecha Local", "Referencia Geográfica", "Magnitud")]  
    }
    
  }, options = list(pageLength = 5, lengthChange = FALSE))
  
})

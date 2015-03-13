shinyServer(function(input, output){

  output$map <- renderLeaflet({

    data <- data %>% 
      mutate(size = (extract_numeric(Magnitud))^2,
             opacity = size/(max(size)*2))
    
    m <- leaflet(data) %>%
      addTiles() %>% 
      addCircleMarkers(lng = ~Longitud, lat = ~Latitud, radius = ~ size, opacity = ~opacity)
    
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

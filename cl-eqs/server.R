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
})

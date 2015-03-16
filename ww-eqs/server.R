shinyServer(function(input, output){
  
  data <- reactive({
    
    data <- data_url %>% 
      filter(between(mag, input$fmag[1], input$fmag[2])) %>% 
      filter(between(depthkm, input$fdepth[1], input$fdepth[2])) %>% 
      filter(region %in% input$fregion)
    
    data
    
  })

  output$map <- renderLeaflet({

    data <- data()
    
    data <- data %>%  mutate(size = (mag^2)*10000)
    
    m <- leaflet(data) %>% addTiles()
    
    if(nrow(data)>0){
      m <- m %>% 
        addCircles(lng = ~lon, lat = ~lat, radius = ~ size, fillOpacity = 0.2, opacity = 0) %>%
        addMarkers(lng = ~lon, lat = ~lat, popup = ~ popup_info)
    }
      
    m
    
  })
  
  output$table <- renderDataTable({
    
    data <- data()
    
    data$popup_info <- NULL
    data
    
  }, options = list(pageLength = 5, lengthChange = FALSE, searching = FALSE, info = FALSE, language = list(url = "json/Spanish.json")))
  
})
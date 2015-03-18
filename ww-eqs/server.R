shinyServer(function(input, output, clientData, session){
  
  data <- reactive({
    
    load("data/data.RData")
    
    if(as.numeric(difftime(Sys.time(), now, units = "mins"))>5){
      data <- download_data()
      now <- Sys.time()
      save(data, now, file = "data/data.RData")  
    }
    
    updateSliderInput(session, "fmag", max = max(data$magnitude))
    updateSliderInput(session, "fdepth", max = max(data$depth))
    
    data <- data %>% 
      filter(between(magnitude, input$fmag[1], input$fmag[2])) %>% 
      filter(between(depth, input$fdepth[1], input$fdepth[2]))
    
    data
    
  })

  output$map <- renderLeaflet({

    data <- data()
    
    data <- data %>%  mutate(size = (magnitude^2)*10000)
    
    m <- leaflet(data) %>% addTiles()
    
    if(nrow(data)>0){
      m <- m %>% 
        addCircles(lng = ~longitude, lat = ~latitude, radius = ~ size, fillOpacity = 0.2, opacity = 0.25,
                   color = "#FFF", fillColor = "#000", popup = ~ popup_info)
    }
      
    m
    
  })
  
  output$table <- renderDataTable({
    
    data <- data()
    
    data %>% select(-popup_info)
    
  }, escape = FALSE,
  options = list(pageLength = 5, lengthChange = FALSE, searching = FALSE,
                 info = FALSE,  pagingType = "full"))
  
})
shinyServer(function(input, output, clientData, session){
  
  
  data_url <- download_data()
  
  updateSliderInput(session, "fmag", min = min(data_url$magnitude), max = max(data_url$magnitude))
  
  updateSliderInput(session, "fdepth", min = min(data_url$depth), max = max(data_url$depth))
  
  data <- reactive({
    
    data <- data_url %>% 
      filter(between(magnitude, input$fmag[1], input$fmag[2])) %>% 
      filter(between(depth, input$fdepth[1], input$fdepth[2]))
    
    data
    
  })

  output$map <- renderLeaflet({

    data <- data()
    
    m <- data %>%
      leaflet() %>%
      addTiles("http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png")
    
    if (nrow(data) > 0) {
      m <- m %>%
        addCircles(lng = ~longitude, lat = ~latitude, radius = ~size,
                   fillOpacity = 0.3, opacity = 0.35, weight = 0,
                   color = "#F0F0F0", fillColor = "#FFF",
                   popup = ~popup_info)
    }
      
    m
    
  })
  
  output$table <- DT::renderDataTable({
    
    data <- data()
    
    d <- data %>% select(-popup_info, -size)
    
    opts <- list(pageLength = 5, lengthChange = FALSE, searching = FALSE,
                 info = FALSE,  pagingType = "full")

    DT::datatable(d, escape = FALSE, rownames = FALSE, options = opts)
    
  })
  
})
shinyServer(function(input, output, session){

  data_url <- download_data()
  
  updateSliderInput(session, "fmagnitud",
                    min = min(data_url$magnitud), max = max(data_url$magnitud),
                    value = c(min(data_url$magnitud), max(data_url$magnitud)))
  
  updateSliderInput(session, "fproundidad",
                    min = min(data_url$profundidad), max = max(data_url$profundidad),
                    value = c(min(data_url$profundidad), max(data_url$profundidad)))
  
  data <- reactive({
    
   data <- data_url %>% 
      filter(between(magnitud, input$fmagnitud[1], input$fmagnitud[2])) %>% 
      filter(between(profundidad, input$fproundidad[1], input$fproundidad[2]))
    
    data
    
  })

  output$map <- renderLeaflet({

    data <- data()
    
    data <- data %>%  mutate(size = (magnitud ^ 2)*10000)
    
    m <- data %>% 
      leaflet() %>%
      addTiles("http://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png")
    
    if (nrow(data) > 0) {
      m <- m %>%
        addCircles(lng = ~longitud, lat = ~latitud, radius = ~size,
                   fillOpacity = 0.3, opacity = 0.35, weight = 0,
                   color = "#F0F0F0", fillColor = "#FFF",
                   popup = ~popup_info)
    }
      
    m
    
  })
  
  output$table <- DT::renderDataTable({
    
    data <- data()
    
    data <- data %>% select(-popup_info, -agencia)
    
    opts <- list(pageLength = 5, lengthChange = FALSE, searching = FALSE,
                 info = FALSE, language = list(url = "json/Spanish.json"))
    
    datatable(data, options = opts, escape = FALSE)
  })
  
})
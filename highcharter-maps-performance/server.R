function(input, output) {
  
  output$hcmap <- renderHighchart({
    
    input$action
    
    data <- mutate(data, value = round(100 * runif(nrow(data)), 2))
    
    if(input$sel == "preload") {
      mapdata <- JS("Highcharts.maps['custom/world-robinson-highres']")
    } else {
      mapdata <- geojson
    }
    
    highchart(type = "map") %>% 
      hc_add_series(mapData = mapdata, data = data, joinBy = c("hc-key"),
                    borderWidth = 0) %>% 
      hc_colorAxis(stops = color_stops())
    
  })
  
}

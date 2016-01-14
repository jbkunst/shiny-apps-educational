function(input, output) {
  
  output$hcontainer <- renderHighchart({
    
    hc <- highchart() %>% 
      hc_chart(type = input$type) %>%
      hc_xAxis(categories = citytemp$month) %>% 
      hc_add_serie(name = "Tokyo", data = citytemp$tokyo) %>% 
      hc_add_serie(name = "London", data = citytemp$london) %>% 
      hc_add_serie(name = "New York", data = abs(citytemp$new_york))
    
    if (input$ena)
      hc <- hc %>% hc_chart(options3d = list(enabled = TRUE, beta = input$beta, alpha = input$alpha))
    
    if (input$stacked != FALSE)
      hc <- hc %>% hc_plotOptions(series = list(stacking = input$stacked))
    
    if (input$credits)
      hc <- hc %>% hc_credits(enabled = TRUE, text = "Highcharter", href = "http://jkunst.com/highcharter/")
    
    if (input$exporting)
      hc <- hc %>% hc_exporting(enabled = TRUE)
    
    if (input$theme != FALSE) {
      theme <- switch(input$theme,
                      darkunica = hc_theme_darkunica(),
                      gridlight = hc_theme_gridlight(),
                      sandsignika = hc_theme_sandsignika()
                      )
      hc <- hc %>% hc_add_theme(theme)
      }
    
    hc
    
  })
  
}
shinyServer(function(input, output, session) {

  data_category <- reactive({
    
    data_category <- data %>% filter(category == input$category)
    
    updateSliderInput(session, "range_price", min = 0, max = max(data_category$price))
    
    data_category
  
    })
  
  data_price <- reactive({
    
    data_price <- data_category()
    data_price <- data_price %>% filter(price %>% between(input$range_price[1], input$range_price[2]))
    
    data_price

  })
  
  output$products <- renderDataTable({
    products <- data_price()
    products
  })

})

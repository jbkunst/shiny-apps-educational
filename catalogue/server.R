input <- list(category = "drinks", price_range = c(0, 100))
values <- list(prod_id = "prod_34")

shinyServer(function(input, output, session) {
  
  # Create a reactiveValues object, to let us use settable reactive values
  values <- reactiveValues()
  values$clicked <- FALSE
  values$prod_id <- NULL
  values$viewas <- NULL
  
  observe({
    if (!is.null(input$clicked) && input$clicked == TRUE) {
      values$prod_id <- input$prod_id
      message(sprintf("viewing %s", values$prod_id))
      updateTabsetPanel(session, "tabset", selected = "Detail")
    }
    
    if(!is.null(input$viewas)){
      values$viewas <- input$viewas
    } else {
      values$viewas <- "grid"
    }
    
        
  })

  data_category <- reactive({
    
    data_category <- data %>% filter(category == input$category)
    
    updateSliderInput(session, "price_range", min = 0, max = max(data_category$price))
    
    updateTabsetPanel(session, "tabset", selected = "Category")

    data_category

    })
  
  data_price <- reactive({
    
    data_price <- data_category()
    
    data_price <- data_price %>% filter(price %>% between(input$price_range[1], input$price_range[2]))
    
    data_price

  })
  
  output$category <- renderUI({
    
    products <- data_price()
    
    if(nrow(products)==0){
      output <- p("There's no products")
    } else {     
     
      
      message(values$viewas)
      if(values$viewas == "grid" ){
        output <- llply(seq(nrow(products)), function(x){
          product_template_grid(products[x,])
        })  
      } else {
        output <- llply(seq(nrow(products)), function(x){
          product_template_list(products[x,])
        })  
      }
      
      output <- do.call(function(...){ div(class="row-fluid", ...)}, output)
    }
    
    output
    
  })
  
  output$product <- renderUI({
    
    prod_id <- str_extract(values$prod_id ,"\\d+") %>% as.numeric
  
    product <- data %>% filter(id == prod_id)
    
    product_detail_template(product)
    
  })
  
  output$cart <- renderUI({
    
    h1("cart")
    
  })

})




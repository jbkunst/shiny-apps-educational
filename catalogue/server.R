input <- list(category = "drinks", price_range = c(0, 100))
values <- list(prod_id = "prod_34")

shinyServer(function(input, output, session) {
  
  # Create a reactiveValues object, to let us use settable reactive values
  values <- reactiveValues()
  values$clicked <- FALSE
  values$prod_id <- NULL
  
  observe({
    if (!is.null(input$clicked) && input$clicked == TRUE) {
      values$prod_id <- input$prod_id
      message(sprintf("viewing %s", values$prod_id))
      updateTabsetPanel(session, "tabset", selected = "tabdetail")
    }
  })

#### Reactive Datas ####
  data_category <- reactive({
    
    data_category <- data %>% filter(category == input$category)
    
    updateSliderInput(session, "price_range", min = 0, max = max(data_category$price))
    updateTabsetPanel(session, "tabset", selected = "tabcategory")
    data_category

    })
  
  data_price <- reactive({
    
    data_price <- data_category()
    
    data_price <- data_price %>% filter(price %>% between(input$price_range[1], input$price_range[2]))
    
    data_price

  })
  
  data_product <- reactive({
    
    prod_id <- str_extract(values$prod_id ,"\\d+") %>% as.numeric
    
    product <- data %>% filter(id == prod_id)
  
  })
  
#### Tab panels ####
  output$category <- renderUI({
    
    products <- data_price()
    
    if(nrow(products)==0){
      output <- p("There's no products")
    } else {     
    
      if(input$viewas == "Grid"){
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
    
    product <- data_product()
    
    product_detail_template(product)
    
  })
  
#### Titles tabpanel ####

  output$tabcategorytitle <- renderUI({
    h4(input$category, tags$small("(", nrow(data_price()),")"))
    })
  
  output$detailtabtitle <- renderUI({
  })
  
  output$carttabtitle <- renderUI({
    h4("Cart", tags$i(class="fa fa-cart"), tags$small("(", 2, ")"))
  })

})




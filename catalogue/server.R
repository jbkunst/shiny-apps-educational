input <- list(category = "drinks", price_range = c(0, 100), sortby = "pl")
values <- list(prod_id = "prod_34", cart = c(1, 4, 5, 6, 6 ,6))

shinyServer(function(input, output, session) {
  
  session$cart <- c()
  # Create a reactiveValues object, to let us use settable reactive values
  values <- reactiveValues()
  values$clicked <- FALSE
  values$prod_id <- NULL
  values$makeorder <- FALSE
  values$cart  <- c()
  
  observe({
    if (!is.null(input$clicked) && input$clicked == TRUE) {
      values$prod_id <- input$prod_id
      updateTabsetPanel(session, "tabset", selected = "tabdetail")
    }
  })
  
  observe({    
    if(!is.null(input$addtocart) && input$addtocart > 0){
      session$cart  <- c(session$cart, isolate(str_extract(input$prod_id, "\\d+")))
      values$cart <- session$cart
    }
  })
  
  observe({
    values$makeorder <- input$makeorder
    if(!is.null(input$makeorder) && values$makeorder){
      message("processing order")
    }
  })

#### Reactive Datas ####
  data_category <- reactive({
    
    data_category <- data %>% filter(category == input$category)
    
    updateSliderInput(session, "price_range", min = 0, max = max(data_category$price))
    
    updateTabsetPanel(session, "tabset", selected = "tabcategory")

    data_category

    })
  
  data_sort <- reactive({
    
    data_sort <- data_category()
    
    if(input$sortby == "pl"){
      data_sort <- data_sort  %>% arrange(price)
    } else if (input$sortby == "ph"){
      data_sort <- data_sort  %>% arrange(desc(price))
    }
    
    data_sort
    
  })
  
  data_price <- reactive({
    
    data_price <- data_sort()
    
    data_price <- data_price %>% filter(price %>% between(input$price_range[1], input$price_range[2]))
    
    data_price

  })
  
  data_product <- reactive({
    
    prod_id <- str_extract(values$prod_id ,"\\d+") %>% as.numeric
    
    product <- data %>% filter(id == prod_id)
  
  })
  
  data_cart <- reactive({
    data_cart <- data_frame(id = as.numeric((values$cart))) %>%
      group_by(id) %>%
      summarize(amount = n()) %>%
      left_join(data, by = "id") %>%
      mutate(subtotal = price*amount,
             subtotal_format = price_format(subtotal),
             product = name,
             price = price_format(price))
    data_cart
  })

#### Titles tabpanel ####

  output$tabcategorytitle <- renderUI({
    h4(input$category, tags$small("(", nrow(data_price()),")"))
    })
  
  output$detailtabtitle <- renderUI({
    if(!is.null(values$prod_id)){
      h4(data_product()$name)
    } else {
      h4("Select a product")
    }
  })
  
  output$carttabtitle <- renderUI({
    input$addtocart
    session$cart
    h4("Cart", tags$i(class="fa fa-cart"), tags$small("(", length(session$cart), ")"))
  })

#### Tab panels ####
  output$category <- renderUI({
    
    products <- data_price()
    
    if(nrow(products)==0){
      output <- simple_text_template("Mmm. There are no products with these characteristics.")
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
    
    if(!is.null(values$prod_id)){
      product <- data_product()
      output <- product_detail_template(product)
    } else {
      output <- simple_text_template("Select a product first please!")
    }
    
    output
    
  })

  output$cart <- renderUI({
    
    if(length(values$cart)==0){
      output <- simple_text_template("Your cart is empty! So we don´t show nothing ;)!")
    } else {     
      dcart <- data_cart()
      output <- cart_template(dcart)
    }
    
    output
  })

})




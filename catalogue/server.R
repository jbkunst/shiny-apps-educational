input <- list(category = "drinks", price_range = c(0, 100), sortby = "pl")
values <- list(prod_id = "prod_34", cart = c(1, 4, 5, 6, 6 ,6))

shinyServer(function(input, output, session) {
  
  # Create a reactiveValues object, to let us use settable reactive values
  session$cart <- c()
  
  values <- reactiveValues()
  values$clicked <- FALSE
  values$prod_id <- NULL
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

#### Reactive Datas ####
  data_category <- reactive({
    
    data_category <- data %>% filter(category == input$category)
    
    updateSliderInput(session, "price_range", min = 0, max = max(data_category$price))
    
    updateTabsetPanel(session, "tabset", selected = "tabcategory")
    
    if(input$sortby == "pl"){
      data_category <- data_category  %>% arrange(desc(price))
    } else if (input$sortby == "ph"){
      data_category <- data_category  %>% arrange(price)
    }
    
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
    h4("Cart", tags$i(class="fa fa-cart"), tags$small("(", length(session$cart), ")"))
  })

#### Tab panels ####
  output$category <- renderUI({
    
    products <- data_price()
    
    if(nrow(products)==0){
      output <- h3("There's no products")
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
      output <- h3("Select a product")
    }
    
    output
    
  })

  output$cart <- renderUI({
    
    
    if(length(values$cart)==0){
      output <- h3("There's no products in your shopping cart")
    } else {     
      dcart <- data_frame(id = as.numeric(values$cart)) %>%
        group_by(id) %>%
        summarize(amount = n()) %>%
        left_join(data, by = "id") %>%
        mutate(subtotal = price*amount,
               subtotal_format = price_format(subtotal),
               product = name,
               price = price_format(price))
      
      cart_total <- dcart$subtotal %>% sum() %>% price_format()
        
      output <- llply(seq(nrow(dcart)), function(x){
        product_cart_tr_template(dcart[x,])
      })
      
      output <- do.call(function(...){ tags$tbody(...)},  output)
      
      output <- div(class="row-fluid table-responsive",
                    tags$table(class="table table-hover",
                      tags$thead(
                        tags$tr(
                          tags$th("Product"),
                          tags$th("Price"),
                          tags$th("Amount"),
                          tags$th("Subtotal")
                          )
                        ),
                      tags$tfoot(
                        tags$tr(
                          tags$th(),
                          tags$th(),
                          tags$th("Total"),
                          tags$th(cart_total)
                          )
                        ),
                      output
                      )
                    )
    }
    
    output

  

  })

})




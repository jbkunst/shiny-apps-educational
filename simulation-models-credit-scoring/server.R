input <- list(
  m1 = c(450, 650),
  m2 = c(250, 750),
  br = 10,
  n = 5000,
  m = 3e6,
  dec = 20
  )

shinyServer(function(input, output) {
  
  df <- reactive({
    set.seed(10)
    df <- data_frame(id = seq_len(input$n)) %>% 
      mutate(
        label = rbinom(input$n, 1, 1 - input$br/100),
        score1 = ifelse(label == 0,
                        rbeta2(n = input$n, mu = input$m1[1]/1000),
                        rbeta2(n = input$n, mu = input$m1[2]/1000)),
        score1 = prob_to_score(score1),
        score2 = ifelse(label == 0,
                        rbeta2(n = input$n, mu = input$m2[1]/1000),
                        rbeta2(n = input$n, mu = input$m2[2]/1000)),
        score2 = prob_to_score(score2)
        )
  })
  
  output$d1 <- renderHighchart({
    df <- df()
    # p <- ggdist(df$label, df$score1, input$dec/100)
    # ggplotly(p)
    hcdist(df$label, df$score1, input$dec/100)
  })
  
  output$d2 <- renderHighchart({
    df <- df()
    # p <- ggdist(label = df$label, score = df$score2, cutoff = input$dec/100) 
    # ggplotly(p)
    hcdist(df$label, df$score2, input$dec/100)
  })
  
  output$ind1 <- renderFormattable({
    df <- df()
    perf(df$label, df$score1) %>% 
      mutate(ks = percent(ks), aucroc = percent(aucroc)) %>% 
      formattable()
  })
  
  output$ind2 <- renderFormattable({
    df <- df()
    perf(df$label, df$score2) %>%
      mutate(ks = percent(ks), aucroc = percent(aucroc)) %>% 
      formattable()
  })
  
  output$m1 <- renderFormattable({
    df <- df()
    mnttbl(df$label, df$score1, input$dec/100, input$m) %>%  fmttb()
  })
  
  output$m2 <- renderFormattable({
    df <- df()
    mnttbl(df$label, df$score2, input$dec/100, input$m) %>%  fmttb()
  })
  
  
  dfbench <- reactive({
    df <- df()
    df1 <- mnttbl(df$label, df$score1, input$dec/100, input$m) %>% 
      select(comportamiento, desicion, monto1 = monto)
    df2 <- mnttbl(df$label, df$score2, input$dec/100, input$m) %>% 
      select(comportamiento, desicion, monto2 = monto)
    
    dfbench <- left_join(df1, df2, by = c("comportamiento", "desicion")) %>% 
      mutate(diferencia = monto2 - monto1,
             diferencia_porcentual = (monto2 - monto1)/monto1,
             diferencia_porcentual = percent(diferencia_porcentual))
    dfbench
  })
  
  output$bench <- renderFormattable({
    dfbench() %>% 
      formattable()
  })
  
  output$bench2 <- renderFormattable({
    
    dfbench <- dfbench()
    
    ventas <- c(dfbench[1,3][[1]] + dfbench[3,3][[1]], dfbench[1,4][[1]] + dfbench[3,4][[1]])
    ventas <- c(ventas, diff(ventas))
    
    pmont <- c(dfbench[3,3][[1]],  dfbench[3,4][[1]])
    pmont <- percent(as.numeric(pmont/ventas[c(1, 2)]))
    pmont <- c(pmont, diff(pmont)/pmont[1])
    
    montomalo <- c((dfbench[1,3][[1]] + dfbench[3,3][[1]])*pmont[1], 
                   (dfbench[1,4][[1]] + dfbench[3,4][[1]])*pmont[2]
                   ,((dfbench[1,4][[1]] + dfbench[3,4][[1]])*pmont[2]) -
                     (dfbench[1,3][[1]] + dfbench[3,3][[1]])*pmont[1])
   
    
    valor <- c("Modelo 1", "Modelo2", "Diferencia")
    
    data_frame("Descripcion" = valor, "Monto" = ventas,"Monto Malo"=montomalo, "% de Monto Malo" = pmont) %>% 
      formattable()
    
    
  })
  
})

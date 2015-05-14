shinyServer(function(input, output) {
  
  url_data <- reactive({
    
    url_data <- html(input$url) %>%
      html_nodes("p, li, h1, h2, h3, h4, h5, h6") %>%
      html_text()
    
    url_data
    
  })
  
  output$d3wc <- renderD3wordcloud({
    
    url_data <- url_data()
    
    corpus <- Corpus(VectorSource(url_data))
    
    corpus <- corpus %>%
      tm_map(removePunctuation) %>%
      tm_map(function(x){ removeWords(x, stopwords()) })
    
    d <- TermDocumentMatrix(corpus) %>%
      as.matrix() %>%
      rowSums() %>%
      sort(decreasing = TRUE) %>%
      data.frame(word = names(.), freq = .) %>%
      tbl_df() %>%
      arrange(desc(freq)) %>%
      head(input$n_words)
    
    d3wordcloud(d$word, d$freq, font = input$font, scale = input$scale, padding = input$padding,
                rotate.min = input$rotate[1], rotate.max = input$rotate[2])
  })
})
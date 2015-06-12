shinyServer(function(input, output) {

  output$d3wc <- renderD3wordcloud({
    
    corpus <- corpus_data[[input$url]]
    
    d <- TermDocumentMatrix(corpus) %>%
      as.matrix() %>%
      rowSums() %>%
      sort(decreasing = TRUE) %>%
      data.frame(word = names(.), freq = .) %>%
      tbl_df() %>%
      arrange(desc(freq)) %>%
      head(input$n_words)
    
    d3wordcloud(d$word, d$freq, font = input$font, font.weight = input$font_weight,
                scale = input$scale, padding = input$padding,
                spiral = input$spiral,
                rotate.min = input$rotate[1], rotate.max = input$rotate[2])
  })
})
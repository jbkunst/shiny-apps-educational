library("tm")
library("rvest")
library("plyr")

urls <- c("http://www.htmlwidgets.org/develop_intro.html",
          "http://r-pkgs.had.co.nz/intro.html",
          "http://adv-r.had.co.nz/Introduction.html",
          "http://rstudio.github.io/shiny-server/latest/",
          "https://github.com/")

corpus_data <- llply(urls, function(url){
  
  url_data <- html(url) %>%
    html_nodes("p, li, h1, h2, h3, h4, h5, h6") %>%
    html_text()
  
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
    arrange(desc(freq))
  
  d
  
}, .progress = "text")

names(corpus_data) <- gsub("http://", "", urls)

save(corpus_data, file = "data.RData")

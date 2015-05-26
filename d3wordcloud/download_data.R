library("rvest")
library("plyr")
library("tm")

urls <- c("http://en.wikipedia.org/wiki/R_(programming_language)",
          "http://www.htmlwidgets.org/develop_intro.html",
          "http://r-pkgs.had.co.nz/intro.html")

corpus_data <- llply(urls, function(url){
  
  url_data <- html(url) %>%
    html_nodes("p, li, h1, h2, h3, h4, h5, h6") %>%
    html_text()
  
  corpus <- Corpus(VectorSource(url_data))
  
  corpus <- corpus %>%
    tm_map(removePunctuation) %>%
    tm_map(function(x){ removeWords(x, stopwords()) }) 
      
  corpus
})

names(corpus_data) <- urls

save(corpus_data, file = "data.RData")

library("shiny")
library("shinydashboard")
library("readr")
library("plyr")
library("dplyr")


download_data <- function(){
  data <- read_csv("data/Ejercicios_Potencias_v1.xlsx - Problemas.csv")
  names(data) <- tolower(names(data))
  data$preg <- gsub("\"", "", data$preg)
  data
}


data <- download_data()

guide_generate <- function(n_preguntas = 2){
  
  md <- "
  ---
  title: 'Untitled'
  author: 'Nosotros'
  ---
  
  # Resuelva los siguiente exs
  
  "
  
  preg_seleccionadas <- sample(seq(nrow(data)), size = n_preguntas)
  
  pregtas_md <- laply(preg_seleccionadas, function(id){ # id <- 1
    
    x <- data[id, ]
    paste("- ", x$cod_enun, x$preg)
    
  })

  md2 <- c(" ",  "# las respuestas son", " ")
  
  respuestas <- laply(preg_seleccionadas, function(id){ # id <- 1
    
    x <- data[id, ]
    paste("- ", x$cod_enun, x$resp_aux)
    
  })
  
  md <- c(md, pregtas_md, md2, respuestas)
  
  writeLines(md, con = "temp.md")
  
  rmarkdown::pandoc_convert(input = "temp.md", output = "temp.pdf")
  
  
}



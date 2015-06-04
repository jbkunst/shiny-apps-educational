# input <- list(guia_nombre = "lala")
shinyServer(function(input, output) {

  output$pdflink <- downloadHandler(
    filename <- function(){
      "temp_out.pdf" 
    },
    content <- function(file) {
      
      guide_generate(input$integer)
      
      file.copy("temp.pdf", file)
    }
  )
  
})



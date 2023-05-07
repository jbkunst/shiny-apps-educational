run_app <- function(app = "kmeans"){
  
  url <- "https://github.com/jbkunst/shiny-apps-edu/archive/refs/heads/master.zip"
  
  filePath <- tempfile("shinyapp", fileext = ".zip")
  fileDir  <- tempfile("shinyapp")  
  
  message("Downloading ", url)
  
  download.file(url, filePath)
  
  try(utils::unzip(filePath, exdir = fileDir))

  fp <- file.path(fileDir, "shiny-apps-edu-master", app)
  
  if(any(stringr::str_detect(dir(fp), "app.Rmd"))) {
    app_rmd <- stringr::str_subset(dir(fp, full.names = TRUE), "app.Rmd")
    rmarkdown::run(app_rmd)
    
  } else {
    # normal shiny
    shiny::runApp(fp)
  }
  
}

# run_app("kmeans")
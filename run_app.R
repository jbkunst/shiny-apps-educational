run_app <- function(app = "kmeans"){
  
  url <- "https://github.com/jbkunst/shiny-apps-educational/archive/refs/heads/master.zip"
  
  filePath <- tempfile("shinyapp", fileext = ".zip")
  fileDir  <- tempfile("shinyapp")  
  
  cli::cli_inform("Downloading {url}")
  
  download.file(url, filePath)
  
  try(utils::unzip(filePath, exdir = fileDir))

  fp <- file.path(fileDir, "shiny-apps-educational-master", app)
  
  shiny::runApp(fp)
  
  # app_rmd <- stringr::str_subset(dir(fp, full.names = TRUE), "app.Rmd")
  # rmarkdown::run(app_rmd)
  
}

# run_app("kmeans")
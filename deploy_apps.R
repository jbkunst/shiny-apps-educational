library(tidyverse)

apps <- dir(recursive = TRUE) |> 
  str_subset("app.R|app.Rmd") |> 
  dirname() |> 
  str_subset("older", negate = TRUE) |> 
  str_subset("\\.", negate = TRUE)

apps_valid <- map(apps, dir) |> 
  map(str_detect, "ui.R|server.R|app.Rmd|app.R") |> 
  map_lgl(any)

apps <- apps[apps_valid]

apps <- setdiff(apps, c("binary-predictions-metrics"))

if(FALSE){
  # delete all rsconnect folders
  fs::dir_ls(recurse = TRUE) |> 
    stringr::str_subset("rsconnect$") |> 
    fs::dir_delete()
}

walk(apps, function(app = "arma-process"){
  
  cli::cli_h1(basename(app))
  cli::cli_inform(app)
  
  if(fs::dir_exists(fs::path(app, "rsconnect"))) return(TRUE)
  
  rsconnect::deployApp(appDir = app, logLevel = "normal", forceUpdate = TRUE)
  
})

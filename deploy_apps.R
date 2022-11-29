library(tidyverse)

# remotes::install_github("jbkunst/highcharter", force = TRUE)
# remotes::install_github("jbkunst/klassets", force = TRUE)
# remotes::install_github("jbkunst/risk3r", force = TRUE)

apps <- fs::dir_ls(here::here(), full.names = TRUE) |>
  str_subset("\\.", negate = TRUE) |> 
  str_subset("older-versions", negate = TRUE) 

if(FALSE){
  # delete all rsconnect folders
  
  fs::dir_ls(recurse = TRUE) |> 
    stringr::str_subset("rsconnect$") |> 
    fs::dir_delete()
  
}

walk(apps, function(app = "D:/Git/shiny-apps/kmeans"){
  
  cli::cli_h1(basename(app))
  cli::cli_inform(app)
  
  if(fs::dir_exists(fs::path(app, "rsconnect"))) return(TRUE)
  
  rsconnect::deployApp(appDir = app, logLevel = "normal")
  
})

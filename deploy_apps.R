library(tidyverse)

# remotes::install_github("jbkunst/highcharter", force = TRUE)
# remotes::install_github("jbkunst/klassets", force = TRUE)

apps <- fs::dir_ls(here::here(), full.names = TRUE) |>
  str_subset("\\.", negate = TRUE) |> 
  str_subset("older-versions", negate = TRUE) 

walk(apps, function(app = "D:/Git/shiny-apps/chess-explorer"){
  
  cli::cli_h2(app)
  
  try(fs::dir_delete(fs::path(app, "rsconnect")))
  
  rsconnect::deployApp(appDir = app, logLevel = "normal")
  
})

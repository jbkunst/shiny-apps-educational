library(shiny)
library(knitr)
library(bslib)
library(stringr)
library(htmltools)
library(markdown)

# matrix2latex funcion is needed in .Rmds
app_dir <- if (dir.exists("rmd")) {
  "."
} else if (dir.exists(file.path("matrix-decompositions", "rmd"))) {
  "matrix-decompositions"
} else {
  "."
}

app_dir <- normalizePath(app_dir, winslash = "/", mustWork = TRUE)
source(file.path(app_dir, "helpers.R"))

theme_matrix <-  bs_theme(
  bg = "#020204",
  fg = "#92E5A1",
  primary = "#22B455"
)

thematic::thematic_shiny(
  bg = "#020204",
  fg = "#92E5A1",
  accent = "#22B455",
  font = "auto"
)

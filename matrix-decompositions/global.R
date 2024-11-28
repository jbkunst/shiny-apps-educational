library(shiny)
library(knitr)
library(bslib)
library(stringr)
library(htmltools)
library(here)
library(markdown)

source("helpers.R")

theme_matrix <-  bs_theme(
  bg = "#020204",
  fg = "#92E5A1",
  primary = "#22B455",
  base_font = font_google("IBM Plex Sans")
) 

matrix2latex <- function(matr) {
  
  out <- apply(matr, 1, function(r) str_c(r, collapse = " & ")) |> 
    str_c(collapse = "\\\\") 
  
  out <- str_c(
    "\\begin{pmatrix}",
    out,
    "\\end{pmatrix}"
  )
  
  out
  
}
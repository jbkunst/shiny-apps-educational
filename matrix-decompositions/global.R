library(shiny)
library(knitr)
library(bslib)
library(stringr)
library(htmltools)
library(here)
library(markdown)

# matrix2latex funcion is needed in .Rmds
source("helpers.R")

theme_matrix <-  bs_theme(
  bg = "#020204",
  fg = "#92E5A1",
  primary = "#22B455",
  base_font = font_google("IBM Plex Sans")
) 
# rm(list = ls())

library("purrr")
library("dplyr")
library("rlist")
library("highcharter")
library("viridisLite")

load("dataappmin.RData")
data("worldgeojson")

thm <- hc_theme_economist()

input <- list(yr = sample(yrs, size = 1), hcworldinput = "Canada")

# rm(list = ls())

library("purrr")
library("dplyr")
library("rlist")
library("highcharter")
library("viridisLite")

load("dataappmin.RData")
data("worldgeojson")

thm <- hc_theme_economist()

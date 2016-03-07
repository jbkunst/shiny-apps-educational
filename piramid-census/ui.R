rm(list = ls())
library("shiny")
library("highcharter")
library("purrr")

shinyUI(fluidPage(

  fluidRow(
    column(6, highchartOutput("hcontainer1")),
    column(6, highchartOutput("hcontainer2")),
    column(6, verbatimTextOutput("hcinputout"))
  ) 
  
))

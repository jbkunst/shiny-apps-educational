# ui.R - Version that works
library(shiny)
library(rCharts)
library(ggplot2)
library(leaflet)


shinyUI(pageWithSidebar(
  headerPanel("test"),
  sidebarPanel(),
  mainPanel(
    tabsetPanel(
      tabPanel("map2", tags$style('.leaflet {height: 400px;}'),showOutput('myChart2', 'leaflet'), plotOutput("myChart1"))
    )
  )
))

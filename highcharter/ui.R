library("shiny")
library("shinydashboard")
library("highcharter")
library("dplyr")
library("viridisLite")
library("markdown")
library("quantmod")
library("ggplot2")
library("treemap")
library("forecast")
library("DT")
rm(list = ls())

dashboardPage(
  skin = "black",
  dashboardHeader(title = "highcharter", disable = FALSE),
  dashboardSidebar(
    sidebarMenu(
      menuItem("Examples", tabName = "examples", icon = icon("bar-chart")),
      menuItem("Time Series", tabName = "ts", icon = icon("line-chart"))
    ),
    div(includeMarkdown("hcterinfo.md"), style = "padding:10px")
  ),
  dashboardBody(
    tags$head(tags$script(src = "js/ga.js")),
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "css/custom_fixs.css")),
    tabItems(
      tabItem(tabName = "examples",
              fluidRow(
                column(4, selectInput("theme", label = "Theme",
                                      choices = c(FALSE, "fivethirtyeight",  "darkunica", "gridlight",
                                                  "sandsignika", "null", "handdrwran", "chalk"))),
                column(4, selectInput("credits", label = "Credits enabled", choices = c(FALSE, TRUE))),
                column(4, selectInput("exporting", label = "Exporting enabled", choices = c(FALSE, TRUE)))
              ),
              box(width = 6, highchartOutput("highchart")),
              box(width = 6, highchartOutput("highmap")),
              box(width = 6, highchartOutput("highohlc")),
              box(width = 6, highchartOutput("highscatter")),
              box(width = 6, highchartOutput("highstreemap")),
              box(width = 6, highchartOutput("highheatmap")),
              box(width = 12, highchartOutput("highstock"))
              ),
      tabItem(tabName = "ts",
              fluidRow(
                column(4, selectInput("ts", label = "Time series",
                                      choices = c("WWWusage", "AirPassengers",
                                                  "ldeaths", "USAccDeaths")))
              ),
              box(width = 12, highchartOutput("tschart")),
              box(width = 6, highchartOutput("tsforecast")),
              box(width = 6, dataTableOutput("dfforecast")),
              box(width = 6, highchartOutput("tsacf")),
              box(width = 6, highchartOutput("tspacf"))
              )
      )
    )
  )



library("shinydashboard")
library("highcharter")
library("dplyr")
library("viridisLite")
library("markdown")
rm(list = ls())

dashboardPage(
  skin = "black",
  dashboardHeader(title = "highcharter", disable = FALSE),
  dashboardSidebar(
    selectInput("theme", label = "Theme",
                choices = c(FALSE, "darkunica", "gridlight", "sandsignika", "null", "chalk")),
    selectInput("credits", label = "Credits enabled", choices = c(FALSE, TRUE)),
    selectInput("exporting", label = "Exporting enabled", choices = c(FALSE, TRUE)),
    div(includeMarkdown("hcterinfo.md"), style = "padding:10px")
  ),
  dashboardBody(
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "css/custom_fixs.css")),
    box(width = 6,  highchartOutput("highchart")),
    box(width = 6,  highchartOutput("highmap")),
    box(width = 6,  highchartOutput("highohlc")),
    box(width = 6,  highchartOutput("highscatter")),
    box(width = 6,  highchartOutput("highstreemap")),
    box(width = 6,  highchartOutput("highheatmap")),
    box(width = 12,  highchartOutput("highstock"))
  )
)



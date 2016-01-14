library("shiny")
library("highcharter")
library("magrittr")
rm(list = ls())
data(citytemp)

shinyUI(
  fluidPage(
    tags$link(rel = "stylesheet", type = "text/css", href = "https://bootswatch.com/paper/bootstrap.css"),
    fluidRow(
      column(width = 3, class = "panel",
             selectInput("type", label = "Type", choices = c("line", "column", "bar", "spline")),
             selectInput("stacked", label = "Stacked", choices = c(FALSE, "normal", "percent")),
             selectInput("credits", label = "Credits enabled", choices = c(FALSE, TRUE)),
             selectInput("exporting", label = "Exporting enabled", choices = c(FALSE, TRUE)),
             selectInput("theme", label = "Theme", choices = c(FALSE, "darkunica", "gridlight", "sandsignika")),
             selectInput("ena", label = "3d enabled", choices = c(FALSE, TRUE)),
             sliderInput("alpha", "Alpha Angle", min = 0, max = 45, value = 15),
             sliderInput("beta", "Beta Angle", min = 0, max = 45, value = 15)
      ),
      column(width = 9,
             highchartOutput("hcontainer",height = "700px")
      )
    )
  )
) 

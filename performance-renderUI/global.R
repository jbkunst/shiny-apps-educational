library(shiny)
library(shinythemes)
library(plotly)
library(highcharter)
library(rbokeh)
library(metricsgraphics)
library(purrr)
library(htmltools)

options(shiny.launch.browser = TRUE)

charts <- list(
  plotly = plot_ly(iris,
                   x = ~Sepal.Length, y = ~Sepal.Width,
                   color = ~Petal.Length, size = ~Petal.Width,
                   text = ~paste("Sepal.Length: ", Sepal.Length)) %>% print(),
  rbokeh = figure() %>%
  ly_points(data = iris,
            Sepal.Length, Sepal.Width,
            color = Petal.Length, size = Petal.Width,
            hover = list(Sepal.Length, Sepal.Width)),
  highcharter = hchart(iris, "scatter",
       hcaes(Sepal.Length, Sepal.Width,
             color = Petal.Length, size = Petal.Width)) %>% print(),
  metricsgraphics = iris %>%
    mjs_plot(x=Sepal.Length, y=Sepal.Width, width=600, height=500) %>%
    mjs_point(color_accessor=Petal.Length, size_accessor=Petal.Width) 
)


map(charts, str, max.level = 3)
map(charts, object.size)
map2(charts, paste0("~/", names(charts), ".html"), htmlwidgets::saveWidget)




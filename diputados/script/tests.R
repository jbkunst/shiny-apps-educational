# devtools::install_github("timelyportfolio/rcdimple") # only for htmlwidget functionality
# devtools::install_github("hrbrmstr/waffle")

library("rcdimple")
library("waffle")

parts <- c(80, 30, 20, 10)
w <- waffle(parts, rows=8)


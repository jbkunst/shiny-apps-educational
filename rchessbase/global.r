library("shiny")
library("shinydashboard")
library("dplyr")
library("rchess")

chessdb <- src_sqlite("data/db.sqlite", create = FALSE)
games <- tbl(chessdb, "games")

head(games, 5)

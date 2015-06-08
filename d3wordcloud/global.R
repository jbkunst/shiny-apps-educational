library("rvest")
library("plyr")
library("tm")

load("data.RData")

choices_font <- c("Impact", "Comic Sans MS (No plz!)" = "Comic Sans MS",
                  "Arial", "Arial Black", "Tahoma", "Verdana", "Courier New",
                  "Georgia", "Times New Roman", "Andale Mono")
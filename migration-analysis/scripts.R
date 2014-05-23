library(rCharts)
library(dplyr)
rm(list=ls())


load("data/master_data.RData")
head(data)

input <- list()
input$destination_selector <- "Mexico"

ncuts <- 100

daux <- subset(data, cntdest_label == as.character(input$destination_selector))
daux <- daux %>% group_by(cntorg) %>% summarise(migvol = sum(na.omit(migvol)))
daux$migvol_cut <- cut(daux$migvol, breaks=unique(quantile(daux$migvol, 1:ncuts/ncuts)), labels=FALSE, include.lowest=TRUE)

colpal <- colorRampPalette(c("yellow", "red"))(length(unique(daux$migvol_cut)))

daux$migvol_cut_color <- colpal[daux$migvol_cut]

ls <- list()
for(i in seq(nrow(daux))){  
  ls[[daux[i,"cntorg"]]] <- list(fillKey = daux[i,"migvol_cut_color"], mig = daux[i,"migvol"])
}

lc <- list()
for(i in seq(length(colpal))){  
  lc[[colpal[i]]] <- colpal[i]
}
lc[['defaultFill']] <- "858585"

m <- rCharts::rCharts$new()
m$setLib('datamaps')
m$set(scope = 'world',
      projection = 'equirectangular',
      data = ls,
      fills = lc,
      geographyConfig = list(highlightFillColor = '585858'))
m

library(foreign)
library(XML)
library(plyr)
rm(list=ls())
options(stringsAsFactors=FALSE)

theurl <- "http://en.wikipedia.org/wiki/ISO_3166-1"
tables <- readHTMLTable(theurl)
tablecodes <- tables[[which.max(unlist(lapply(tables, function(t) dim(t)[1])))]]

head(tablecodes)
tablecodes <- tablecodes[, c(1,3)]
names(tablecodes) <- c("country", "code")
head(tablecodes)


data <- read.dta("data/master_data.dta")
head(data[,1:4])
names(tablecodes) <- c("cntorg_label", "cntorg")
data <- join(data, tablecodes)

names(tablecodes) <- c("cntdest_label", "cntdest")
data <- join(data, tablecodes)

str(data)
class(data)
data <- as.data.frame(data)
# save(data, file="data/master_data.RData")


i1 <- "Chile"
i2 <- c("Australia", "Afghanistan", "Peru")

daux <- subset(data, cntdest_label == i1)
daux$cntorg_label <- ifelse(daux$cntorg_label %in% i2, daux$cntorg_label, "Other")
daux <- daux %.% group_by(year, cntorg_label) %.% summarise(migvol = sum(na.omit(migvol)))
p <- hPlot(migvol ~ year, data = daux, type = 'area', group = 'cntorg_label', radius = 0)
p$plotOptions(area = list(stacking= 'percent'))
p$tooltip(pointFormat = '<span style="color:{series.color}">{series.name}</span>: <b>{point.percentage:.1f}%</b> ({point.y:,.0f} millions)<br/>', shared = 'true')
p


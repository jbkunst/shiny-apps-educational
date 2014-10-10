#### Packages ####
rm(list=ls())
# install.packages("XML")
library(XML)


#### load xml ####
xmltop <- xmlRoot(xmlTreeParse("data.xml"))
# have a look at the XML-code of the first subnodes:
df <- data.frame(t(xmlSApply(xmltop, function(x) xmlSApply(x, xmlValue))),row.names=NULL)
head(df)

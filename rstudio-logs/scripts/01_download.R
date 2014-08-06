rm(list=ls())
library(plyr)

folder <- "../data_raw"

suppressWarnings(dir.create(folder))

days_all <- seq(as.Date('2012-10-01'), Sys.Date(), by = 'day')
days_all <- as.character(days_all)

days_missing <- setdiff(days_all, tools::file_path_sans_ext(dir(path = folder), TRUE))
years_missing <- as.POSIXlt(days_missing)$year + 1900

urls <- paste0('http://cran-logs.rstudio.com/', years_missing, '/', days_missing, '.csv.gz')

l_ply(urls, function(url){ # url <- sample(urls, size = 1)
  message(url)
  try_default(download.file(url, destfile = file.path(folder, basename(url))), 
              message(sprintf("File %s not found", url )))  
})

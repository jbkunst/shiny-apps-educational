source("00_parameters_and_packages.R")


suppressWarnings(dir.create(pars$folder_data_raw))


days_all <- seq(as.Date('2012-10-01'), Sys.Date(), by = 'day')
days_all <- as.character(days_all)


days_missing <- setdiff(days_all, tools::file_path_sans_ext(dir(path = pars$folder_data_raw), TRUE))
years_missing <- as.POSIXlt(days_missing)$year + 1900


urls <- paste0('http://cran-logs.rstudio.com/', years_missing, '/', days_missing, '.csv.gz')
urls <- if(length(days_missing)!=0) urls else NULL


l_ply(urls, function(url){ # url <- sample(urls, size = 1)
  try_default(download.file(url, destfile = file.path(pars$folder_data_raw, basename(url))), 
              message(sprintf("File %s not found", url )))  
})

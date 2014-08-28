source("00_parameters_and_packages.R")


d$date_revert <- format(as.POSIXct(d$timestamp, tz = "GMT", origin = "1970-01-01"), "%Y-%m-%d")
d$time_revert <- format(as.POSIXct(d$timestamp, tz = "GMT", origin = "1970-01-01"), "%H:%M:%S") 
start <- as.numeric(strptime(paste(file_date, "00:00:00"), "%Y-%m-%d %H:%M:%S"))
end <- as.numeric(strptime(paste(file_date, "23:59:59"), "%Y-%m-%d %H:%M:%S"))

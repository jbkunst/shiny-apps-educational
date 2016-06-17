# dateHour
x <- "2016051801"
datetime_to_timestamp(ymd_h(x))

# yearWeek
x <- c("201621", "201622")
x %>% paste(1) %>% as.Date(format = "%Y%U %u")
x 


# yearMonth
x <- c("201605", "201606")
as.Date(x, "%Y%m")
x %>% paste0("01") %>% ymd()


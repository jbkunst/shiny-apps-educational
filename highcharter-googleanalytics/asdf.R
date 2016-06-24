index <- c("medium", "source", "referralPath")
size <- "sessions"
color <- "bounceRate"
maxcats <- 20

aggFun <- sample(list(sum, median, max, mean), size = 1)[[1]]
aggFun(c(1:10))


df <- ga$getData(ID, start.date = Sys.Date() - 20, end.date = daterange[2],
           metrics = "ga:sessions,ga:bounceRate",
           dimensions = "ga:source,ga:referralPath",
           filter = "ga:medium==referral") %>% 
  tbl_df() %>% 
  arrange(desc(sessions)) 

hc_add_series_treemap <- function (hc, tm, ...) 
{
  # assertthat::assert_that(.is_highchart(hc), is.list(tm))
  df <- tm$tm %>% tbl_df() %>%
    select_("-x0", "-y0", "-w", "-h", "-stdErr", "-vColorValue", "-color") %>% 
    rename_(value = "vSize", 
            colorValue = "vColor") %>% purrr::map_if(is.factor, as.character) %>% 
    data.frame(stringsAsFactors = FALSE) %>% tbl_df()
  
  ndepth <- which(names(df) == "value") - 1
  
  ds <- map_df(seq(ndepth), function(lvl) {
    df2 <- df %>% filter_(sprintf("level == %s", lvl)) %>% 
      rename_(name = names(df)[lvl]) %>% mutate_(id = "highcharter::str_to_id(name)")
    if (lvl > 1) {
      df2 <- df2 %>% mutate_(parent = names(df)[lvl - 1], 
                             parent = "highcharter::str_to_id(parent)")
    }
    else {
      df2 <- df2 %>% mutate_(parent = NA)
    }
    df2
  })
  ds <- list.parse3(ds)
  ds <- map(ds, function(x) {
    if (is.na(x$parent)) 
      x$parent <- NULL
    x
  })
   hc_add_series(highchart(), data = ds, type = "treemap",
                 layoutAlgorithm = "squarified",
                 allowDrillToNode = TRUE, ...) %>% 
     hc_colorAxis(stops = color_stops())
}

tm <- treemap::treemap(business,
        index=c("NACE1", "NACE2"),
        vSize="employees",
        vColor="employees.prev",
        type="value",
        palette="RdYlGn",
        range=c(-20000,30000),           # this is shown in the legend
        mapping=c(-30000, 10000, 40000))
# tm <- treemap::treemap(df, index[-1], size, color)
hct <-hc_add_series_treemap(highchart(), tm,
                      # layoutAlgorithm = "squarified",
                      allowDrillToNode = TRUE)
hct
bind_rows(
  purrr::map_df(head(hct$x$hc_opts$series[[1]]$data), as.data.frame),
  purrr::map_df(head(list.parse3(dft)), as.data.frame)
)


highchart() %>% 
  hc_add_series(
    type = "treemap",
    layoutAlgorithm = "squarified",
    allowDrillToNode = TRUE,
    data = series
  ) %>% 
  hc_colorAxis()

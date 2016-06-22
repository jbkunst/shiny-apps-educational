df <- ga$getData(ID, start.date = Sys.Date()-10, end.date = daterange[2],
           metrics = "ga:sessions,ga:bounceRate",
           dimensions = "ga:medium,ga:source,ga:referralPath") %>% 
  tbl_df() %>% 
  arrange(desc(sessions)) 

df <- ga$getData(ID, start.date = Sys.Date()-10, end.date = daterange[2],
                 metrics = "ga:sessions,ga:bounceRate",
                 dimensions = "ga:source,ga:referralPath",
                 filter="ga:medium==referral") %>% 
  tbl_df() %>% 
  arrange(desc(sessions)) 

df
  
aggFun <- sample(list(sum, median, max, mean), size = 1)[[1]]
aggFun(c(1:10))

index <- c("medium", "source", "referralPath")
size <- "sessions"
color <- "bounceRate"

stopifnot(is.data.frame(df),
          is.character(c(index, size, color)),
          index %in% names(df),
          size %in% names(df),
          color %in% names(df))

library("data.tree")

df$pathString <- paste("root", df$medium, df$source, df$referralPath,   sep = "|")
df$pathString <- paste("root", df$medium, df$source,   sep = "|")

s <- as.Node(df, mode="table", pathDelimiter = "|")

s$Do(function(node){
  if(!is.null(size)){
    node$value <- Aggregate(node , attribute = size, aggFun = aggFun)
  }
  if(!is.null(color)){
    node$colorValue  <- Aggregate(node , attribute = color, aggFun = aggFun)
  }
})

# assign ids to all nodes
s$Set(id = 1:s$totalCount)
s$Set(parent1 = c(function(self) GetAttribute(self$parent, "id", format = identity)))


vars <- c(index, "value", "colorValue", "level", "id", "parent1")
dft <- do.call(function(...) data.tree:::print.Node(..., limit = Inf), c(s, vars))
dft <- tbl_df(data.frame(dft))

# dft <- dft[-1, ]
dft$level <- dft$level - 0
dft$id <- dft$id - 0

dft <- fill_(dft, fill_cols = index, "up") 

nms <- dft %>%
  select_(.dots = c(index, "level")) %>% 
  purrr::by_row(function(x){
    as.character(x[, x$level])
  }) %>%
  unnest() %>% 
  .$.out

dft$name <- nms
dft$id <- paste0("id", dft$id)
dft$parent <- paste0("p", dft$parent1)
dft$parent1 <- NULL
dft$levelName <- NULL
dft <- dft[, setdiff(names(dft), index)]

series <- list.parse3(dft)
series <- purrr::map(series, function(x){
  if(x$parent == x$id) x$parent <- NULL
  x
})


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

hct <-hc_add_series_treemap(highchart(), tm <- treemap::treemap(df, index[-1], size, color),
                      layoutAlgorithm = "squarified",
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

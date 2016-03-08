shinyServer(function(input, output) {

  output$hcworld <- renderHighchart({
    
    fn <- "function(){
      console.log(this.name);
      Shiny.onInputChange('hcworldinput', this.name)
    }"

    df2aux <- df2 %>% 
      filter(time == 2016)
      # filter(time == input$yr)
    
    n <- 32
    dstops <- data.frame(q = 0:n/n, c = substring(viridis(n + 1, option = "B"), 0, 7))
    dstops <- list.parse2(dstops)
    
    highchart() %>% 
      hc_add_series_map(worldgeojson, df2aux, value = "wage", joinBy = c("iso3"), name = "Median age") %>% 
      hc_title(text = "Median age by country, 2016") %>% 
      hc_colorAxis(min = 10, max = 60,
                   stops = dstops) %>% 
      hc_legend(layout = "vertical", reversed = TRUE,
                verticalAlign = "middle",
                floating = TRUE, align = "right") %>% 
      hc_mapNavigation(enabled = TRUE, align = "right",
                       buttonOptions = list(verticalAlign = "bottom")) %>% 
      hc_plotOptions(
        series = list(
          cursor = "pointer",
          point = list(
            events = list(
              click = JS(fn)
            )
          )
        )
      ) %>% 
      hc_add_theme(thm)
    
  })
  
  output$hcpopiramid <- renderHighchart({

    nme <- ifelse(is.null(input$hcworldinput), "United States of America", input$hcworldinput)
    
    cod <- df2 %>% filter(name == nme) %>% .$iso3 %>% .[1]

    dfp <- df %>%  filter(time == input$yr, iso3 == cod)

    xaxis <- list(categories = sort(unique(dfp$age)),
                  reversed = FALSE, tickInterval = 5,
                  labels = list(step = 10))
    
    highchart() %>%
      hc_chart(type = "bar", animation = FALSE) %>%
      hc_title(text = sprintf("Population pyramid for %s, %s", nme, input$yr )) %>% 
      hc_plotOptions(series = list(stacking = "normal"),
                     bar = list(groupPadding = 0, pointPadding =  0, borderWidth = 0)) %>% 
      hc_legend(enabled = FALSE) %>% 
      hc_tooltip(shared = FALSE,
                 formatter = JS("function () { return '<b>' + this.series.name + ', age ' + this.point.category + '</b><br/>' + 'Population: ' + Highcharts.numberFormat(Math.abs(this.point.y), 0);}")
                 ) %>% 
      hc_yAxis(visible = FALSE) %>% 
      hc_xAxis(
        xaxis,
        list.merge(xaxis, list(opposite = TRUE, linkedTo = 0))
        ) %>% 
      hc_add_serie(data = dfp %>% filter(sex == "male") %>% .$pop %>% {-1*.},
                   name = "male") %>% 
      hc_add_serie(data = dfp %>% filter(sex == "female") %>% .$pop,
                   name = "female") %>% 
      hc_add_theme(thm)

  })

  output$hctss <- renderHighchart({
    
    nme <- ifelse(is.null(input$hcworldinput), "Canada", input$hcworldinput)
    
    med <- df2 %>% 
      filter(time == 2016, name == nme) %>% 
      .$wage  
    
    cntries <- df2 %>% 
      filter(time == 2016, wage > med - 1, wage < med + 1) %>% 
      .$name  
    
    df2aux <- df2 %>% 
      filter(name %in% cntries)
    
    fn <- "function(){
      console.log(this.name);
      Shiny.onInputChange('hcworldinput', this.name)
    }"
    
    hctss <- highchart() %>% 
      hc_chart(type = "spline") %>% 
      hc_title(text = "Median age by years") %>% 
      # hc_yAxis(min = 10, max = 60) %>% 
      hc_plotOptions(
        series = list(
          states =  list(
            hover = list(
              enabled = TRUE,
              halo = list(
                size = 0
              )
            )
          ),
          animation = FALSE,
          showInLegend = FALSE,
          cursor = "pointer",
          events = list(
            click = JS(fn)
            )
          ),
         point = list(
           events = list(
             click = JS(fn)
           )
         )
        ) %>% 
      hc_xAxis(categories = yrs) %>% 
      hc_add_theme(thm)
    
    for (nm in (unique(df2aux$name))) {

      hctss <- hctss %>%
        hc_add_series(data = df2aux %>% filter(name == nm) %>% .$wage,
                      color = "rgba(118, 192, 193, 0.8)", zIndex = -3,
                      name = nm, marker = list( radius = 0))
    }

    ds <- df2aux %>% filter(name == nme) %>% .$wage
    ds <- map(ds, function(x) x)
    tmp <- ds[which(input$yr == yrs)][[1]]
    ds[[which(input$yr == yrs)]] <- list(y = tmp, marker = list(symbol = "circle", color = "white", radius = 5,
                                                                fillColor = "#014d64", lineWidth = 3))
    
    hctss <- hctss %>% 
      hc_add_series(data = ds, color = "#014d64", zIndex = 1,  name = nme, lineWidth = 4,
                    marker = list(symbol = "circle", radius = 1))
    
    hctss
    
    
  })
 

})

usdjpy <- getSymbols("USD/JPY", src = "oanda", auto.assign = FALSE)
eurkpw <- getSymbols("EUR/KPW", src = "oanda", auto.assign = FALSE)

data(citytemp, package = "highcharter")
data(worldgeojson, package = "highcharter")
data(sample_matrix, package = "xts")
data(GNI2010, package = "treemap")
data(diamonds, package = "ggplot2")

dscounts <- dplyr::count(diamonds, cut) %>% 
  setNames(c("name", "value")) %>% 
  list.parse3()



dsheatmap <- tbl_df(expand.grid(seq(12) - 1, seq(5) - 1)) %>% 
  mutate(value = abs(seq(nrow(.)) + 10 * rnorm(nrow(.))) + 10,
         value = round(value, 2)) %>% 
  list.parse2()


f <- exp
dshmstops <- data.frame(q = c(0, f(1:5)/f(5)), c = substring(viridis(5 + 1), 0, 7)) %>% 
  list.parse2()

function(input, output) {
  
  hcbase <- reactive({
    # hcbase <- function() highchart() 
    hc <- highchart() 
    

    if (input$credits)
      hc <- hc %>% hc_credits(enabled = TRUE, text = "Highcharter", href = "http://jkunst.com/highcharter/")
    
    if (input$exporting)
      hc <- hc %>% hc_exporting(enabled = TRUE)
    
    if (input$theme != FALSE) {
      theme <- switch(input$theme,
                      null = hc_theme_null(),
                      darkunica = hc_theme_darkunica(),
                      gridlight = hc_theme_gridlight(),
                      sandsignika = hc_theme_sandsignika(),
                      chalk = hc_theme_chalk()
      )
      
      hc <- hc %>% hc_add_theme(theme)
    }
    
    hc
    
  })
  
  output$highchart <- renderHighchart({
    
    hcbase() %>% 
      hc_xAxis(categories = citytemp$month) %>% 
      hc_add_series(name = "Tokyo", data = citytemp$tokyo) %>% 
      hc_add_series(name = "London", data = citytemp$london)
    
  })
  
  output$highstock <- renderHighchart({
    
    hcbase() %>% 
      hc_add_series_xts(usdjpy, id = "usdjpy") %>% 
      hc_add_series_xts(eurkpw, id = "eurkpw")
    
  })
  
  output$highmap <- renderHighchart({
    
    hcbase() %>% 
      hc_add_series_map(worldgeojson, GNI2010, value = "GNI", joinBy = "iso3") %>% 
      hc_colorAxis(stops = dshmstops) 
    
  })
  
  output$highscatter <- renderHighchart({
    
    hcbase() %>% 
      hc_add_series_scatter(mtcars$wt, mtcars$mpg,
                            mtcars$drat, mtcars$hp,
                            rownames(mtcars),
                            dataLabels = list(
                              enabled = TRUE,
                              format = "{point.label}"
                            ))
    
  })
  
  output$highstreemap <- renderHighchart({
    
    hcbase() %>% 
      hc_add_series(data = dscounts, type = "treemap", colorByPoint = TRUE) 
    
  })
  
  output$highohlc <- renderHighchart({
    
    hcbase() %>% 
      hc_add_series_ohlc(as.xts(sample_matrix))
    
  })

  output$highheatmap <- renderHighchart({
    
    hcbase() %>% 
      hc_chart(type = "heatmap") %>% 
      hc_xAxis(categories = month.abb) %>% 
      hc_yAxis(categories = 2016 - length(dsheatmap)/12 + seq(length(dsheatmap)/12)) %>% 
      hc_add_series(name = "value", data = dsheatmap) %>% 
      hc_colorAxis(min = 0) 
    
  })
  
  
}
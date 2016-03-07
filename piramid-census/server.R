input <- list(yr = sample(yrs, size = 1),
              hcworldinput = "CAN")

shinyServer(function(input, output) {

  output$hcworld <- renderHighchart({
    
    fn <- "function(){
      console.log(this.name);
      Shiny.onInputChange('hcworldinput', this.iso3)
    }"

    df2aux <- df2 %>% 
      filter(time == 2015)
      # filter(time == input$yr)
    
    highchart() %>% 
      hc_add_series_map(worldgeojson, df2aux, value = "wage", joinBy = c("iso3")) %>% 
      hc_colorAxis(min = 10, max = 60) %>% 
      hc_plotOptions(
        series = list(
          cursor = "pointer",
          point = list(
            events = list(
              click = JS(fn)
            )
          )
        )
      ) 
    
  })
  
  output$hcpopiramid <- renderHighchart({

    cod <- ifelse(is.null(input$hcworldinput), "CAN", input$hcworldinput)

    dfp <- df %>% 
      filter(time == input$yr, iso3 == cod)

    xaxis <- list(categories = sort(unique(dfp$age)),
                  reversed = FALSE, tickInterval = 2,
                  labels = list(step = 5))
    
    highchart() %>%
      hc_chart(type = "bar", animation = FALSE) %>%
      hc_plotOptions(series = list(stacking = "normal"),
                     bar = list(groupPadding = 0, pointPadding =  0, borderWidth = 0)) %>% 
      hc_legend(enabled = FALSE) %>% 
      hc_tooltip(shared = TRUE) %>% 
      hc_yAxis(visible = FALSE) %>% 
      hc_xAxis(
        xaxis,
        list.merge(xaxis, list(opposite = TRUE))
        ) %>% 
      hc_add_serie(data = dfp %>% filter(sex == "male") %>% .$pop %>% {-1*.},
                   name = "male") %>% 
      hc_add_serie(data = dfp %>% filter(sex == "female") %>% .$pop,
                   name = "female")

  })

  output$hctss <- renderHighchart({
    hctss
  })
 

})

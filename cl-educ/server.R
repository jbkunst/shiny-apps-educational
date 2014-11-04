# input <- list(colegio_rbd = 10088, indicador = "simce_mate")
load("data/app_data.RData")

shinyServer(function(input, output) {
  
  output$plot <- renderChart2({
    
    d1 <- d %>%
      select(rbd, agno, value = get(input$indicador)) %>%
      group_by(agno) %>%
      summarize(n = n(),
                n.val = sum(!is.na(value)),
                p25 = quantile(value, .25, na.rm = TRUE),
                p50 = quantile(value, .50, na.rm = TRUE),
                p75 = quantile(value, .75, na.rm = TRUE))
    
    d2 <- d %>%
      filter(rbd==input$colegio_rbd) %>%
      select(agno, value = get(input$indicador))
    
    d3 <- join(d1, d2, by ="agno")

    # Plot
    p <- Highcharts$new()
    
    p$series(name = paste(input$indicador), data = d3$value, type ="line", lineWidth = 5, color="#F0F0F0")
    p$series(name = "percentil 50", data = d3$p50, type ="line", lineWidth = 1, dashStyle="dash", color="#FCFCFC")
    p$series(name = "percentil 25", data = d3$p25, type ="line", lineWidth = 1, dashStyle="dot", color="#FCFCFC")
    p$series(name = "percentil 75", data = d3$p75, type ="line", lineWidth = 1, dashStyle="dot", color="#FCFCFC")
    
    p$xAxis(categories = d3$agno)
    
    p$plotOptions(line = list(marker = list(enabled = FALSE)))
    
    p
    
  })

  output$map_chile <- renderPlot({
    
    chi_shp <- readShapePoly("data/chile_shp/cl_regiones_geo.shp")
    chi_f <- fortify(chi_shp)
    p <- ggplot()+ 
      geom_polygon(data=chi_f,aes(long,lat,color=id,group=group, fill="white", alpha = 0.1))+
      coord_equal() + theme_null()
    p
    
  }, bg="transparent")
  
})
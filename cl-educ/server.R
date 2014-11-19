# input <- list(colegio_rbd = 1, indicador = "psu_matematica",
#               colegio_misma_region = TRUE, colegio_misma_dependencia = TRUE, colegio_misma_area = TRUE,
#               region_numero = "3")

shinyServer(function(input, output) {
  
  data <- reactive({

    colegios_new <- colegios
    d_colegio <- colegios %>% filter(rbd == input$colegio_rbd)
    
    if(input$colegio_misma_region){
      colegios_new <- colegios_new %>% filter(numero_region %in% d_colegio$numero_region)
    }
    if(input$colegio_misma_dependencia){
      colegios_new <- colegios_new %>% filter(dependencia %in% d_colegio$dependencia)
    }
    if(input$colegio_misma_area){
      colegios_new <- colegios_new %>% filter(area_geografica %in% d_colegio$area_geografica)
    }
    
    data <- d %>% filter(rbd %in% colegios_new$rbd)
    
  })
  
  output$plot_colegio <- renderChart2({
    
    data <- data()
    colegio_nombre <- colegios %>% filter(rbd == input$colegio_rbd) %>% .$nombre_establecimiento
      
    d1 <- data %>%
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
    
    p$series(name = colegio_nombre, data = d3$value, type ="line", lineWidth = 5, color="#F0F0F0")
    p$series(name = "Mediana", data = d3$p50, type ="line", lineWidth = 1, dashStyle="dash", color="#FCFCFC")
    p$series(name = "25% peor", data = d3$p25, type ="line", lineWidth = 1, dashStyle="dot", color="#FCFCFC")
    p$series(name = "25% mejor", data = d3$p75, type ="line", lineWidth = 1, dashStyle="dot", color="#FCFCFC")
    
    p$xAxis(categories = d3$agno)
    
    p$plotOptions(line = list(marker = list(enabled = FALSE)))
    
    p$set(width = "100%" ,height = "100%")
    
    p
    
  })

  output$report_colegio <- renderUI({
    
    drow <- data() %>%
      select(rbd, value = get(input$indicador)) %>%
      filter(!is.na(value) & rbd == input$colegio_rbd) %>%
      nrow()
   
    if(drow != 0){
      report_file <- "report/report_colegio.rmd"
    } else {
      report_file <- "report/report_colegio_no_indicator.rmd"
    }
    HTML(knitr::knit2html(text = readLines(report_file), fragment.only = TRUE, quiet = TRUE))
  })
  
  output$map_chi_reg <- renderPlot({
    head(chi_map)
    
    chi_map <- chi_map %>% mutate(flag=ifelse(newid==as.numeric(input$region_numero),"1","0"))
      
    ggplot(chi_map)+ 
      geom_polygon(aes(long,lat, fill=flag,group=group), color="white") +
      scale_fill_manual(values = c("transparent", "white"))+
      coord_equal() + theme_null()
    
  }, bg="transparent")
  
})

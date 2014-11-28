# input <- list(colegio_rbd = 1, indicador = "psu_matematica",
#               colegio_misma_region = TRUE, colegio_misma_dependencia = TRUE, colegio_misma_area = TRUE,
#               region_numero = "5", region_indicador = "simce_leng",
#               region_map_size = 3, region_map_alpha = .5)

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
  
  data_reg <- reactive({
    
    max_agno <- max(colegios$max_agno)
    data_reg <- colegios %>% filter(max_agno ==  max_agno & numero_region == input$region_numero)
    d_reg <- d %>%
      filter(agno == max_agno & rbd %in% data_reg$rbd) %>%
      mutate(simce_leng_cat = cut(simce_leng, c(100,250,270,300)),
             simce_mate_cat = cut(simce_mate, c(100,250,270,300)),
             psu_lenguaje_cat = cut(psu_lenguaje, c(200,400,500,600,850)),
             psu_matematica_cat = cut(psu_matematica, c(200,400,500,600,850)),
             max_agno=as.character(agno))
    
    data_reg <- left_join(data_reg, d_reg, by = c("rbd", "max_agno"))
    
    if(input$region_indicador=="dependencia"){
      data_reg <- data_reg %>% mutate(value=dependencia)
    } else if(input$region_indicador=="area_geografica") {
      data_reg <- data_reg %>% mutate(value=area_geografica)
    } else if(input$region_indicador=="simce_mate"){
      data_reg <- data_reg %>% mutate(value=simce_mate_cat)
    } else if(input$region_indicador=="simce_leng"){
      data_reg <- data_reg %>% mutate(value=simce_leng_cat)
    } else if(input$region_indicador=="psu_matematica"){
      data_reg <- data_reg %>% mutate(value=psu_lenguaje_cat)
    } else if(input$region_indicador=="psu_lenguaje"){
      data_reg <- data_reg %>% mutate(value=psu_lenguaje_cat)
    } 
    
    data_reg

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
   
    report_file <- ifelse(drow != 0, "colegio.rmd", "colegio_no_indicator.rmd")
    
    HTML(knitr::knit2html(text = readLines(sprintf("report/%s", report_file), warn = FALSE), fragment.only = TRUE, quiet = TRUE))
    
  })
  
  output$map_chi_reg <- renderPlot({
        
    chi_map <- chi_map %>% mutate(flag=ifelse(newid==as.numeric(input$region_numero),"1","0"))
      
    ggplot(chi_map) +
      geom_polygon(aes(long,lat, fill=flag,group=group), color="white") +
      scale_fill_manual(values = c("transparent", "white")) +
      coord_equal() +
      theme_null()
    
  }, bg="transparent")
  
  output$plot_region <- renderChart2({  
    
    df <- data_reg()    
    df <-  df %>%
      filter(!is.na(value)) %>%
      group_by(value) %>%
      summarise(n=n()) 
      
    p <- rCharts:::Highcharts$new()
    p$chart(type = "column")
    p$plotOptions(column = list(stacking = "normal"))
    p$xAxis(categories = df$value)
    p$series(name = "Cantidad", data = df$n)
    p$set(width = "100%", height = "100%")
    p
  })
  
  output$report_region <- renderUI({
    HTML(knitr::knit2html(text = readLines(sprintf("report/%s", "region.rmd"), warn = FALSE), fragment.only = TRUE, quiet = TRUE))
  })
  
  output$map_reg <- renderPlot({
    
    region_f <- fortify(readShapePoly(sprintf("data/regiones_shp/r%s.shp", input$region_numero)))
    
    region_colegios <- data_reg()
    region_colegios <- region_colegios %>%
      filter(!is.na(longitud) & longitud!=0 & !is.na(latitud) & latitud!=0)
    
    if(grepl("simce|psu",input$region_indicador)){
      region_colegios$value <- region_colegios[[input$region_indicador]]
    }
    
    title_legend <- names(which(region_indicador_choices == input$region_indicador))
    
    p <- ggplot() +
      geom_polygon(data=region_f, aes(long, lat, group=group), color="white", fill="transparent") +
      geom_point(data=region_colegios, aes(longitud, latitud, color=value),
                 size = input$region_map_size, alpha = input$region_map_alpha)
    if(is.numeric(region_colegios$value)){
      p <- p + scale_colour_gradient(title_legend,low="darkred", high="green")
    } else {
      p <- p + scale_colour_discrete(title_legend)
    }
    p <- p +
      coord_equal() +
      theme_null() +
      theme_legend()
    p
    
  }, bg="transparent")
  
})

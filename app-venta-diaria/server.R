input <- list(segmento = sample(segmento_choices, size = 1), path = sample(path_choices, size = 1))

shinyServer(function(input, output, session) {
  
  output$sols_per_plot <- renderPlotly({
    
    df_aux <- dfressol %>% 
      filter(segmento_label == input$segmento, desc_path_sw == input$path) %>% 
      group_by(periodo) %>% 
      summarise(count = sum(count))
  
    p <- ggplot(df_aux, aes(periodo, count)) +
      geom_line(color = "#dd4b39") +
      geom_point(size = 5, color = "#dd4b39") + 
      ylim(c(0, NA))
    p
    
    p <- ggplotly(p)
    p
  
  })
  
  output$sols_per_ri_plot <- renderPlotly({
    
    df_aux <- dfressol %>% 
      filter(segmento_label == input$segmento, desc_path_sw == input$path) %>% 
      group_by(periodo, risk_indicator) %>% 
      summarise(count = sum(count))
    
    p <- ggplot(df_aux, aes(periodo, count, color = risk_indicator)) +
      geom_line() +
      geom_point(size = 5) +
      scale_color_manual(values = c("E" = "#800000", "D" = "#FF0000", "C" = "#FFD700", "B" = "#2E8B57",
                                    "A" = "#1E90FF"))
    p
    p <- ggplotly(p)
    p

  })
  
  output$sols_per_swsol_plot <- renderPlotly({
    
    df_aux <- dfressol %>% 
      filter(segmento_label == input$segmento, desc_path_sw == input$path) %>% 
      group_by(periodo, resultado_sw) %>% 
      summarise(count = sum(count))

    p <- ggplot(df_aux, aes(periodo, count, color = resultado_sw)) +
      geom_line() +
      geom_point(size = 5) +
      scale_color_manual(values = c("Rechazado" = "#800000", "Devuelta" = "#FF0000",
                                    "Zona de Analisis" = "#FFD700", "Aceptado" = "#1E90FF"))
    p
    p <- ggplotly(p)
    p
    
  })
  
  output$perd_per_sina <- renderPlotly({
    
    df_aux <- dfperf %>% 
      filter(segmento_label == input$segmento, desc_path_sw == input$path) %>% 
      select(periodo, bg, score_sinacofi, score_interno) %>% 
      gather(modelo, score, -periodo, -bg) %>% 
      group_by(periodo, modelo) %>% 
      do({
        perf(.$bg, .$score)
        }) %>% 
      ungroup() %>% 
      select(periodo, modelo, ks, aucroc) %>% 
      gather(indicator,  value, -periodo, -modelo)
    
    p <- ggplot(df_aux, aes(periodo, value)) +
      geom_line() +
      geom_point(size = 5) +
      facet_grid(indicator~modelo, scales = "free") + 
      ylim(c(0, NA))
    
    p
    p <- ggplotly(p)
    p
  
  })
  
  output$ri_per_plot <- renderPlot({
    
    query <- "select camada, risk_indicator, count(*) as count
    from rt_scoring.dbo.sw_sols_res
    where segmento_label = '%s' and desc_path_sw = '%s' and camada >= 201301
    group by camada, risk_indicator" %>% sprintf(input$segmento, input$path)
    
    df_aux <- tbl_df(sqlQuery(chn, query)) %>%
      mutate(periodo = paste0(camada, "01") %>% ymd(),
             risk_indicator = addNA(factor(risk_indicator, levels = LETTERS[1:5], ordered = TRUE)))
    
#     tauchart(df_aux) %>% 
#       tau_line(c("periodo"), c("count"), color = "risk_indicator") %>% 
#       tau_color_manual(c("#031F61", "#01B0F1","#FFFF04", "#FE0000", "#BD0100", "#4c3862")) %>% 
#       tau_guide_x(auto_scale = TRUE, tick_format = "%Y%b", tick_period = "year") %>%  
#       tau_legend() %>%
#       tau_tooltip()

    ggplot(df_aux) +  geom_line(aes(periodo, count, color = risk_indicator))
    
  })
  
})

# dtest <- tbl_df(sqlQuery(chn, "select top 1000 * from rt_scoring.dbo.sw_sols_res"))
# table(dtest$n_risk, dtest$risk_indicator)
# dtest$resultado_sw
# dput(names(table(dtest$desc_path_sw)))

# dtest <- tbl_df(sqlQuery(chn, "select top 100 * from [lnkmaca].[ods].[dbo].[fact_vectorstrategy]"))
# names(dtest) <- tolower(names(dtest))


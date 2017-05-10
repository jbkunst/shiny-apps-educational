# input <- list(
#   image = sample(img_choices, 1),
#   k1 = sample(1:10, size = 1),
#   k2 = sample(100, 10000, size = 1)
#   )

shinyServer(function(input, output) {
  
  rgbImage <- reactive({
    
    message(sprintf("reading %s", input$image))
    readImage <- readJPEG(input$image)
    dim(readImage)
    
    message("processing image")
    rgbImage <- map(1:3, function(i) readImage[,,i]) %>% 
      map(tbl_df) %>% 
      map(function(d){ mutate(d, y = seq_len(nrow(d))) }) %>% 
      map(gather, x, c, -y) %>% 
      reduce(left_join, by = c("x", "y")) %>% 
      dplyr::rename(r = c.x, g = c.y, b = c) %>% 
      mutate(
        x = as.numeric(gsub("V", "", x)),
        y = rev(y),
        rgb = rgb(r, g, b)
        ) 
    
  })
  
  output$originalImage <- renderPlot({
    rgbImage <- rgbImage()
    plot(rgbImage$x, rgbImage$y, col = rgbImage$rgb,
         asp = 1, pch = ".", ylab = "", xlab = "", xaxt="n", yaxt = "n", axes = FALSE)
    
  })
  
  output$resultImage1 <- renderPlot({
    rgbImage <- rgbImage()
    
    kMeans <- rgbImage %>% 
      select(r, g, b) %>% 
      kmeans(centers = input$k1)
    
    rgbImage <- rgbImage %>%
      mutate(rbgApp = rgb(kMeans$centers[kMeans$cluster, c("r", "g", "b")])) %>% 
      tbl_df()
    
    plot(rgbImage$x, rgbImage$y, col = rgbImage$rbgApp, asp = 1, pch = ".",
         ylab = "", xlab = "", xaxt="n", yaxt="n", axes=FALSE)
    
  })
  
  output$resultImage2 <- renderPlot({
    rgbImage <- rgbImage()
    
    kMeans <- rgbImage %>% 
      select(x, y, r, g, b) %>% 
      kmeans(centers = input$k2)
    
    rgbImage <- rgbImage %>%
      mutate(rbgApp = rgb(kMeans$centers[kMeans$cluster, c("r", "g", "b")])) %>% 
      tbl_df()
    
    plot(rgbImage$x, rgbImage$y, col = rgbImage$rbgApp, asp = 1, pch = ".",
         ylab = "", xlab = "", xaxt="n", yaxt="n", axes=FALSE)
    
  })
  
  
  output$originaltDist <- renderPlot({
    
    rgbImage <- rgbImage()
    
    rgbImage_aux <- rgbImage %>%
      group_by(rgb) %>%
      summarise(n=n()) %>%
      arrange(desc(n)) %>%
      head(10) %>% 
      arrange(n) %>%
      mutate(rgb = factor(rgb, levels = rgb),
             proportion = n/nrow(rgbImage)) 
    
    p <- ggplot(rgbImage_aux) +
      geom_bar(aes(x= rgb, y=proportion, fill= rgb), color="grey90", stat="identity") +
      scale_fill_manual(values=as.character(rgbImage_aux$ rgb)) + 
      coord_flip() + theme_bw() + scale_y_continuous(label=percent) +
      theme_gg_custom()
    
    p
    
  })
  
  output$resultDist <- renderPlot({
    
    rgbImage <- rgbImage()
    
    rgbImage_aux <- rgbImage %>%
      group_by(rbgApp) %>%
      summarise(n=n()) %>%
      arrange(n) %>%
      mutate(rbgApp = factor(rbgApp, levels = rbgApp),
             proportion = n/nrow(rgbImage)) 
    
    p <- ggplot(rgbImage_aux) +
      geom_bar(aes(x=rbgApp, y=proportion, fill=rbgApp), color="grey90", stat="identity") +
      scale_fill_manual(values=as.character(rgbImage_aux$rbgApp)) + 
      coord_flip() + theme_bw() + scale_y_continuous(label=percent) +
      theme_gg_custom()
    
    print(p)
    
  })

  output$scatterplot3d <- renderScatterplotThree({
    
    rgbImage <- rgbImage()
    
    rgbImage_sample <- rgbImage %>%
      sample_n(500) %>% 
      .$rgb %>% 
      col2rgb() %>% 
      t() %>% 
      data.frame() %>% 
      tbl_df() %>% 
      mutate(rbg = rgb(red/255, green/255, blue/255, 0.5)) %>% 
      as.data.frame() %>% 
      mutate(label = sprintf("rgb (%s, %s, %s)", red, green, blue))
    
    scatterplot3js(rgbImage_sample[,1:3], color=rgbImage_sample$rbg, labels=rgbImage_sample$label, renderer="canvas")
  })
  
  output$scatterplot3dresult <- renderScatterplotThree({
    
    rgbImage <- rgbImage()
    
    rgbImage_aux <- rgbImage %>%
      group_by(rbgApp) %>%
      summarise(n=n()) %>%
      arrange(n) %>%
      mutate(proportion = n/nrow(rgbImage))
    rgbImage_aux <- cbind(rgbImage_aux, col2rgb(rgbImage_aux$rbgApp) %>% t)
    
    scatterplot3js(rgbImage_aux[,c("red", "green", "blue")], size = log(rgbImage_aux$proportion*1000),
                   color=rgbImage_aux$rbgApp, renderer="canvas")
  })
  
})

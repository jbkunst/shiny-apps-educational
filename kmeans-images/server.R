input <- list(image = sample(img_choices, 1), k = sample(seq(3, 5), size = 1))

shinyServer(function(input, output) {
  
  rgbImage <- reactive({
    
    message(sprintf("reading %s", input$image))
    readImage <- readJPEG(input$image)
    
    message("processing image")
    longImage <- melt(readImage)
    rgbImage <- reshape(longImage, timevar = "X3", idvar = c("X1", "X2"), direction = "wide")
    rgbImage <- rgbImage %>%
      mutate(X1 = -X1,
             rgb = rgb(value.1, value.2, value.3))
    
    message(sprintf("kmeans algorithm: %s", input$k))
    kColors <- input$k
    kMeans <- kmeans(rgbImage %>% select(value.1, value.2, value.3), centers = kColors)
    
    rgbImage <- rgbImage %>% mutate(rbgApp = rgb(kMeans$centers[kMeans$cluster, ])) %>% 
      tbl_df()
    
  })
  
  output$originalImage <- renderPlot({
    
    rgbImage <- rgbImage()
  
    plot(rgbImage$X2, rgbImage$X1, col = rgbImage$rgb, asp = 1, pch = ".",
         ylab = "", xlab = "", xaxt="n", yaxt="n", axes=FALSE)
    
  })
  
  output$resultImage <- renderPlot({
    
    rgbImage <- rgbImage()
    
    plot(rgbImage$X2, rgbImage$X1, col = rgbImage$rbgApp, asp = 1, pch = ".",
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
    
    print(p)
    
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

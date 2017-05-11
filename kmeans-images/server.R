# input <- list(
#   image = sample(img_choices, 1),
#   k1 = sample(1:10, size = 1),
#   k2 = sample(100, 10000, size = 1)
#   ); input

shinyServer(function(input, output) {
  
  image <- reactive({
    
    image <- readJPEG(input$image)
    image
    
  })
  
  df_image <- reactive({
    
    image <- image()
    
    message("processing image")
    df_image <- map(1:3, function(i) image[,,i]) %>% 
      map(matrix_to_df) %>% 
      reduce(left_join, by = c("x", "y")) %>% 
      rename(r = c.x, g = c.y, b = c) %>% 
      mutate(rgb = rgb(r, g, b)) 
    
  })
  
  gray_image <- reactive({
    
    image <- image()
    
    fcts <- c(0.21, 0.72, 0.07)
    
    gray_image <- map(1:3, function(i) image[,,i]) %>% 
      map2(fcts, `*`) %>% 
      reduce(`+`)
    
    gray_image
    
  })
  
  output$originalImage <- renderPlot({
    df_image <- df_image()
    plot(df_image$x, df_image$y, col = df_image$rgb,
         asp = 1, pch = ".", ylab = "", xlab = "", xaxt="n", yaxt = "n", axes = FALSE)
    
  })
  
  output$resultImage1 <- renderPlot({
    
    df_image <- df_image()
    
    kMeans <- df_image %>% 
      select(r, g, b) %>% 
      kmeans(centers = input$k1)
    
    df_image <- df_image %>%
      mutate(rbgApp = rgb(kMeans$centers[kMeans$cluster, c("r", "g", "b")])) %>% 
      tbl_df()
    
    plot(df_image$x, df_image$y, col = df_image$rbgApp, asp = 1, pch = ".",
         ylab = "", xlab = "", xaxt="n", yaxt="n", axes=FALSE)
    
  })
  
  output$resultImage2 <- renderPlot({
    df_image <- df_image()
    
    kMeans <- df_image %>% 
      select(x, y, r, g, b) %>% 
      kmeans(centers = input$k2)
    
    df_image <- df_image %>%
      mutate(rbgApp = rgb(kMeans$centers[kMeans$cluster, c("r", "g", "b")])) %>% 
      tbl_df()
    
    plot(df_image$x, df_image$y, col = df_image$rbgApp, asp = 1, pch = ".",
         ylab = "", xlab = "", xaxt="n", yaxt="n", axes=FALSE)
    
  })
  
  output$grayImage <- renderPlot({
    
    gray_image <- gray_image()
    
    # df_gray <- matrix_to_df(gray_image) %>% 
    #   mutate(rgb = rgb(0, 0, 0, alpha = 1 - c))
    # 
    # plot(df_gray$x, df_gray$y, col = df_gray$rgb,
    #      asp = 1, pch = ".", ylab = "", xlab = "", xaxt="n", yaxt="n", axes=FALSE)
    
    img <- rotate_m(gray_image)
    graphics::image(img, axes = FALSE, col = grey(seq(0, 1, length = 256)))
  })
  
  output$filterImage <- renderPlot({
    
    gray_image <- gray_image()
    
    fltr <- matrix(c(0, -1, 0, -1, 5, -1, 0, -1, 0), nrow = 3)
    # fltr <- matrix(rep(1/9, 9), nrow = 3)
    
    filter_image <- matrix(NA, nrow = nrow(gray_image), ncol = ncol(gray_image))
    
    for(i in 2:(ncol(gray_image) - 1)) { 
      for(j in 2:(nrow(gray_image) - 1)) {
        msub <- gray_image[(j-1):(j+1), (i-1):(i+1)]
        filter_image[j, i] <- sum(msub * fltr)
        # message(i, ", ",  j)
        # print(msub)
      }
    }
    
    # df_filter <- matrix_to_df(filter_image) %>% 
    #   filter(!is.na(c)) %>% 
    #   mutate(
    #     c =  (c - min(c)) / ( max(c) - min(c)),
    #     rgb = rgb(0, 0, 0, alpha = 1 - c)
    #     ) 
    # 
    # plot(df_filter$x, df_filter$y, col = df_filter$rgb, type = "o",
    #      asp = 1, pch = ".", ylab = "", xlab = "", xaxt="n", yaxt="n", axes=FALSE)
    img <- rotate_m(filter_image)
    graphics::image(img, axes = FALSE, col = grey(seq(0, 1, length = 256)))
  })
  
  # output$originaltDist <- renderPlot({
  #   
  #   df_image <- df_image()
  #   
  #   df_image_aux <- df_image %>%
  #     group_by(rgb) %>%
  #     summarise(n=n()) %>%
  #     arrange(desc(n)) %>%
  #     head(10) %>% 
  #     arrange(n) %>%
  #     mutate(rgb = factor(rgb, levels = rgb),
  #            proportion = n/nrow(df_image)) 
  #   
  #   p <- ggplot(df_image_aux) +
  #     geom_bar(aes(x= rgb, y=proportion, fill= rgb), color="grey90", stat="identity") +
  #     scale_fill_manual(values=as.character(df_image_aux$ rgb)) + 
  #     coord_flip() + theme_bw() + scale_y_continuous(label=percent) +
  #     theme_gg_custom()
  #   
  #   p
  #   
  # })
  # 
  # output$resultDist <- renderPlot({
  #   
  #   df_image <- df_image()
  #   
  #   df_image_aux <- df_image %>%
  #     group_by(rbgApp) %>%
  #     summarise(n=n()) %>%
  #     arrange(n) %>%
  #     mutate(rbgApp = factor(rbgApp, levels = rbgApp),
  #            proportion = n/nrow(df_image)) 
  #   
  #   p <- ggplot(df_image_aux) +
  #     geom_bar(aes(x=rbgApp, y=proportion, fill=rbgApp), color="grey90", stat="identity") +
  #     scale_fill_manual(values=as.character(df_image_aux$rbgApp)) + 
  #     coord_flip() + theme_bw() + scale_y_continuous(label=percent) +
  #     theme_gg_custom()
  #   
  #   print(p)
  #   
  # })
  # 
  # output$scatterplot3d <- renderScatterplotThree({
  #   
  #   df_image <- df_image()
  #   
  #   df_image_sample <- df_image %>%
  #     sample_n(500) %>% 
  #     .$rgb %>% 
  #     col2rgb() %>% 
  #     t() %>% 
  #     data.frame() %>% 
  #     tbl_df() %>% 
  #     mutate(rbg = rgb(red/255, green/255, blue/255, 0.5)) %>% 
  #     as.data.frame() %>% 
  #     mutate(label = sprintf("rgb (%s, %s, %s)", red, green, blue))
  #   
  #   scatterplot3js(df_image_sample[,1:3], color=df_image_sample$rbg, labels=df_image_sample$label, renderer="canvas")
  # })
  # 
  # output$scatterplot3dresult <- renderScatterplotThree({
  #   
  #   df_image <- df_image()
  #   
  #   df_image_aux <- df_image %>%
  #     group_by(rbgApp) %>%
  #     summarise(n=n()) %>%
  #     arrange(n) %>%
  #     mutate(proportion = n/nrow(df_image))
  #   df_image_aux <- cbind(df_image_aux, col2rgb(df_image_aux$rbgApp) %>% t)
  #   
  #   scatterplot3js(df_image_aux[,c("red", "green", "blue")], size = log(df_image_aux$proportion*1000),
  #                  color=df_image_aux$rbgApp, renderer="canvas")
  # })
  
})

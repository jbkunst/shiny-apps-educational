library("shiny")
library("threejs")

input <- list(N=100)

shinyServer(function(input, output) {

  v <- reactive({
    h <- 100
    data(world.cities, package="maps")
    
    cities <- world.cities[order(world.cities$pop,decreasing=TRUE)[1:input$N],]
    
    value <- h * cities$pop / max(cities$pop)
    
    # THREE.Color only accepts RGB form, drop the A value:
    col <- sapply(heat.colors(10), function(x) substr(x,1,7))
    names(col) <- c()
    # Extend palette to data values
    col <- col[floor(length(col)*(h-value)/h) + 1]
    v <- list(value=value, color=col, cities=cities)
  })

  output$globe <- renderGlobe({
    
    v <- v()
    
    earth_dark <- system.file("images/world.jpg",package="threejs")
    
    atmo <- TRUE
    
    args = c(col[[input$map]] , list(lat=v$cities$lat, long=v$cities$long, value=v$value, color=v$color, atmosphere=atmo))
    
    do.call(globejs, args=args)
  })
  
})


# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyServer(function(input, output) {

  output$hcontainer1 <- renderHighchart({
    fn <- "function(){
    console.log('Category: ' + this.category + ', value: ' + this.y + ', series: ' + this.series.name);
    ds = this.series.data.map(function(e){ return {x: e.x, y: e.y  }  }); 
    Shiny.onInputChange('hcinput', {category: this.category, name: this.series.name, data: ds, type: this.series.type})
    }"

    hc <- highchart() %>%
      hc_add_series(data = c(3.9,  4.2, 5.7, 8.5), type = "column",
                    name = "draggable", draggableY = TRUE, dragMinY = 0) %>% 
      hc_add_series(data = 2*c(7, 6.9,  9.5, 14), type = "scatter",
                    name = "draggable too!", draggableX = TRUE, draggableY = TRUE) %>%
      hc_add_series(data = 3*c(2,  0.6, 3.5, 8), type  = "spline") %>% 
      hc_plotOptions(
        series = list(
          cursor = "pointer",
          point = list(
            events = list(
              click = JS(fn),
              drop = JS(fn)
            )
          )
        )
      ) 
    
    hc
    
  })
  
  output$hcontainer2 <- renderHighchart({

    hcinput <- input$hcinput

    highchart() %>%
      hc_title(text = hcinput$category) %>%
      hc_add_serie(data = hcinput$data, type = hcinput$type, name = hcinput$name)

  })

  output$hcinputout <- renderPrint({
    
    inputaux <- input$hcinput
    
    if (!is.null(inputaux))
      inputaux$data <- map_df(inputaux$data, as_data_frame)
    
    inputaux
    
  })
  

})

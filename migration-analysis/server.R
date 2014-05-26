require(shiny)
require(rCharts)
require(dplyr)

load("data/master_data.RData")
# input <- list()
# input$destination_selector <- "Chile"
# input$origin_selector <- c("Peru", "Argentina")
  
shinyServer(function(input, output) {

  output$table <- renderDataTable({
    daux <- subset(data, cntdest_label == as.character(input$destination_selector))
    daux <- daux %.% group_by(cntorg_label) %.% summarise(migvol = sum(na.omit(migvol))) %.% arrange(desc(migvol))
    daux <- cbind(rank = seq(nrow(daux)), daux)
    daux
  }, options = list(aLengthMenu = c(5, 10, 20), iDisplayLength = 10))  

  output$log <- renderPrint(
    list(input$origin_selector, input$destination_selector)
  )
  
  output$map <- renderChart2({
       
    daux <- subset(data, cntdest_label == as.character(input$destination_selector))
    daux <- daux %>% group_by(cntorg) %>% summarise(migvol = sum(na.omit(migvol)))
    
    ncuts <- 100
    faux <- function(x){ log(x) }
    rng <- range(faux(daux$migvol+1))
    sqn <- seq(from=rng[1], to=rng[2], length.out=ncuts)
    
    daux$migvol_cut <- cut(faux(daux$migvol+1), breaks=sqn, labels=FALSE, include.lowest=TRUE)
    colpal <- colorRampPalette(c("yellow", "red"))(ncuts)
    daux$migvol_cut_color <- colpal[daux$migvol_cut]
    
    
    ls <- list()
    for(i in seq(nrow(daux))){  
      ls[[daux[i,"cntorg"]]] <- list(fillKey = daux[i,"migvol_cut_color"], mig = daux[i,"migvol"])
    }
    ls[[unique(data$cntdest[data$cntdest_label == input$destination_selector])]] <- 
      list(fillKey = "#3333CC", mig = "")
    
    lc <- list()
    for(i in seq(length(colpal))){  
      lc[[colpal[i]]] <- colpal[i]
    }
    lc[['defaultFill']] <- "858585"
    lc[['#3333CC']] <- "#3333CC"
    
    m <- rCharts::rCharts$new()
    m$setLib('datamaps')
    m$set(scope = 'world',
          projection = 'equirectangular',
          data = ls,
          fills = lc,
          geographyConfig = list(highlightFillColor = '585858'))
    m
  })
  
  
  
  output$plot <- renderChart2({
    
    daux <- subset(data, cntdest_label == as.character(input$destination_selector))
    daux$cntorg_label <- ifelse(daux$cntorg_label %in% input$origin_selector, daux$cntorg_label, "Other")
    
    daux <- daux %.% group_by(year, cntorg_label) %.% summarise(migvol = sum(na.omit(migvol)))

    p <- hPlot(migvol ~ year, data = daux, type = 'area', group = 'cntorg_label', radius = 0)
    p$chart(backgroundColor = 'rgba(0 , 0, 0, 0)')
    p$set(width = "100%", height= "100%")
    if(input$plot_type == "area_percent"){
      p$plotOptions(area = list(stacking= 'percent'))
      p$tooltip(pointFormat = '<span style="color:{series.color}">{series.name}</span>: <b>{point.percentage:.1f}%</b> ({point.y})<br/>', shared = 'true')
    } else if(input$plot_type == "area"){
      p$plotOptions(area = list(stacking= 'normal'))
      p$tooltip(pointFormat = '<span style="color:{series.color}">{series.name}</span>: <b>{point.percentage:.1f}%</b> ({point.y})<br/>', shared = 'true')
    } else {
      p$chart(backgroundColor = 'rgba(0 , 0, 0, 0)', type = input$plot_type)
    }
    
    return(p)
  })
})
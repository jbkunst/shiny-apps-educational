shinyUI(
  fluidPage(
    tags$link(rel = "stylesheet", type = "text/css", href = "css/bootstrap.cosmo.min.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css"),
    tags$script(src = "js/custom.js"),
    
    fluidRow(id = "header",
             column(6,
                    h4("MyMarkterWE")
                    )
             ),
    fluidRow(id = "main",
             column(width = 3, id = "sidebar",
                    hr(),
                    radioButtons("category", "Category", choices = unique(data$category)),
                    hr(),
                    sliderInput("price_range", "Prices",  min = 0, max = 1e9, value = c(0, 1e9), pre="$"),
                    actionLink("price_reset", "reset prices", class = "small pull-right"),
                    br(),
                    hr(),
                    tags$label("View as"),
                    br(),
                    div(id = "viewas", class="btn-group", 'data-toggle'="buttons",
                        tags$label(class="btn btn-primary active",
                                   tags$input(type="radio", name="options", value="grid", autocomplete="off"),
                                   tags$i(class="fa fa-th")),
                        tags$label(class="btn btn-primary",
                                   tags$input(type="radio", name="options", value="list", autocomplete="off"),
                                   tags$i(class="fa fa-list"))
                        )
                    
                    
                    
                    
                    ),
             column(width = 9, id = "contentbar",
                    hr(),
                    tabsetPanel(id="tabset", type = "pills",
                                tabPanel(uiOutput("categrytab"), value = "Category",
                                         hr(),
                                         uiOutput("category")),
                                tabPanel(uiOutput("detailtab"), value = "Detail",
                                         hr(),
                                         uiOutput("product")),
                                tabPanel(uiOutput("carttab"), value = "Cart", 
                                         hr(),
                                         uiOutput("cart"))
                                )
                    )
             ),
    fluidRow(id = "footer",
             column(6, offset = 5, class = "text-right",
                    h5(tags$i(class="fa fa-facebook"), "myfacebook"),
                    h5(tags$i(class="fa fa-twitter"), "mytwitter"),
                    h5(tags$i(class="fa fa-send"), "myemail@mydomain.my"),
                    h5(tags$i(class="fa fa-copyright"), "2005 myname")
                    )
      )
    )
  )
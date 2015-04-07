shinyUI(
  fluidPage(
    # Site
    tags$link(rel = "stylesheet", type = "text/css", href = "css/bootstrap.cosmo.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/custom.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/hover.css"),
    tags$script(src = "js/custom.js"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/selectize_custom.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "//maxcdn.bootstrapcdn.com/font-awesome/4.3.0/css/font-awesome.min.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "https://cdnjs.cloudflare.com/ajax/libs/sweetalert/0.5.0/sweet-alert.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "css/sweet-alert_custom.css"),
    tags$script(src = "https://cdnjs.cloudflare.com/ajax/libs/sweetalert/0.5.0/sweet-alert.min.js"),
    fluidRow(
      id = "header",
      column(
        6,
        h3("MyMarkterWE", tags$small("Subtitle"))
        )
      ),
    fluidRow(
      id = "main",
      column(
        width = 3, id = "sidebar",
        hr(),
        radioButtons("category", "Category", choices = unique(data$category)),
        hr(),
        sliderInput("price_range", "Prices",  min = 0, max = 1e9, value = c(0, 1e9), pre="$", sep = ".", width = "100%"),
        actionLink("price_reset", "reset prices", class = "small pull-right"),
        br(),
        hr(),
        selectInput("sortby", "Sort",
                    choices = c("Time: newly listed" = "tr", "Price: lowest first" = "pl", "Price: highest first" = "ph"),
                    width = "100%"),
        hr(),
        radioButtons("viewas", "View", choices = c("Grid", "List"), inline = TRUE)
        ),
      column(
        width = 9, id = "contentbar",
        hr(),
        tabsetPanel(
          id="tabset", type = "pills",
          tabPanel(uiOutput("tabcategorytitle"), value = "tabcategory", hr(), uiOutput("category")),
          tabPanel(uiOutput("detailtabtitle"), value = "tabdetail", hr(), uiOutput("product")),
          tabPanel(uiOutput("carttabtitle"), value = "tabcart",  hr(), uiOutput("cart"))
          )
        )
      ),
    fluidRow(
      id = "footer",
      column(
        6, offset = 6, class = "text-right",
        h5(tags$i(class="fa fa-facebook"), "myfacebook"),
        h5(tags$i(class="fa fa-twitter"), "mytwitter"),
        h5(tags$i(class="fa fa-send"), "myemail@mydomain.my"),
        h5(tags$i(class="fa fa-copyright"), "2005 myname")
        )
      )
    )
  )
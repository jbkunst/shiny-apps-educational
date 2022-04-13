title <- function(...) stri_trans_totitle(...)

price_format <- function(x){
  paste("$", prettyNum(x, big.mark = ".", decimal.mark = ","))
}

get_data_sample <- function(){
  library("arules")
  data(Groceries)
  set.seed(1313)
  data <- Groceries@itemInfo %>%
    mutate(id = sample(nrow(.)),
           name = as.character(labels) %>% title,
           category = as.character(level1) %>% title,
           description = as.character(level2)  %>% title,
           details = text_sample(),
           price = round(runif(nrow(.))*100)*100) %>%
    select(id, name, category, price, description, details) %>%
    tbl_df   
    
}

text_sample <- function(){
  "Bitters Helvetica whatever tousled, fanny pack roof party master cleanse paleo freegan iPhone sriracha. Williamsburg forage freegan narwhal leggings trust fund. Meditation freegan tote bag viral. Farm-to-table keytar biodiesel Schlitz paleo readymade, roof party retro lo-fi mumblecore Intelligentsia Banksy"
}

product_template_grid <- function(x){
  
  # x <- sample_n(data, 1)
  
  column(3, class="prodbox hvr-reveal", id = sprintf("prod_%s", x$id),
         div(class="prodboxinner",
             img(class="imgthumb img-responsive center-block",
                 src=sprintf("http://placehold.it/200x200&text=%s", x$name))
             ),
         div(class="prodboxinner",
             h5(x$name)
             ),
         a(href="",
           div(class="panel-footer prodboxinner",
               span(class="pull-left", price_format(x$price)),
               span(class="pull-right", tags$i(class="fa fa-arrow-circle-right")),
               div(class="clearfix")
              )
           )
         )
}

product_template_list <- function(x){
  
  # x <- sample_n(data, 1)
  
  column(12, class="prodbox", id = sprintf("prod_%s", x$id),
         fluidRow(
            column(4,
                   img(class="imgthumb img-responsive center-block",
                       src=sprintf("http://placehold.it/200x200&text=%s", x$name))
                   ),
            column(4,
                   h5(x$name)
                   ),
            column(4,
                   price_format(x$price)
                   )
           )
         )
         
       
}

product_detail_template <- function(x){
  
  # x <- sample_n(data, 1)
  
  div(class="row-fluid",
      column(4,
             div(class="row-fluid",
                 column(6, img(class="imgthumb img-responsive", src=sprintf("http://placehold.it/200x200&text=%s", x$name))),
                 column(6, img(class="imgthumb img-responsive", src=sprintf("http://placehold.it/200x200&text=%s", x$name))),
                 column(6, img(class="imgthumb img-responsive", src=sprintf("http://placehold.it/200x200&text=%s", x$name))),
                 column(6, img(class="imgthumb img-responsive", src=sprintf("http://placehold.it/200x200&text=%s", x$name))),
                 column(6, img(class="imgthumb img-responsive", src=sprintf("http://placehold.it/200x200&text=%s", x$name))),
                 column(6, img(class="imgthumb img-responsive", src=sprintf("http://placehold.it/200x200&text=%s", x$name)))
                 )
             ),
      column(8,
             h3(x$name),
             tags$dl(
                     tags$dt("Desciption"), tags$dd(x$description),
                     tags$dt("Details"), tags$dd(x$details),
                     tags$dt("Stock"), tags$dd(5)
                     ),
             hr(),
             div(class="row-fluid",
                 column(6,
                        tags$button(class="btn btn-success btn-lg", price_format(x$price))
                        ),
                 column(6,
                        actionButton("addtocart", class="pull-right btn-success btn-lg hvr-buzz-out", prodid = x$id,
                                     "  Add to cart", tags$i(class="fa fa-cart-plus"))
                        )
                 )
             )
      )
}

cart_template <- function(dcart){
  
  cart_total <- dcart$subtotal %>% sum %>% price_format
  
  products_template_tr <- llply(seq(nrow(dcart)), function(y){
    x <- dcart[y,]
    tags$tr(
      tags$td(class="text-center",
              img(class="imgthumb img-responsive", src=sprintf("http://placehold.it/40x40&text=%s", x$name))),
      tags$td(x$product),
      tags$td(class="text-right", x$price),
      tags$td(class="text-right", x$amount),
      tags$td(class="text-right", x$subtotal_format)
    )
  })
  
  products_template_tr <- do.call(function(...){ tags$tbody(...)},  products_template_tr)
  
  div(class="row-fluid",
      div(class="table-responsive",
          tags$table(class="table table-hover",
                     tags$thead(
                       tags$tr(
                         tags$th(),
                         tags$th("Product"),
                         tags$th(class="text-right", "Price"),
                         tags$th(class="text-right", "Amount"),
                         tags$th(class="text-right", "Subtotal")
                         )
                       ),
                     products_template_tr,
                     tags$tfoot(
                       tags$tr(
                         tags$th(),
                         tags$th(),
                         tags$th(),
                         tags$th(class="text-right", "Total"),
                         tags$th(class="text-right", cart_total)
                         )
                       )
                     )
          ),
      actionButton("checkout", class="pull-right btn-success btn-lg hvr-buzz-out",
                   "  Check out", tags$i(class="fa fa-money")),
      tags$script(src = "js/checkout_sweet_alert.js")
      )
}

simple_text_template <- function(x){
  h3(x)
}
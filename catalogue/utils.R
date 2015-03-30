get_data <- function(){
  key <- KEY_GSS
  ss <- register_ss(key)
  data <- ss %>%  get_via_csv() 
  data
}

product_template <- function(){
  column(3,
         div(class="productbox",
             div(class="imgthumb img-responsive",
                 img(src="http://lorempixel.com/250/250/business/?ab=1df")
             )
         ),
         div(class="caption",
             h5("Lorem ipsum dolor sit amet"),
             a(href="", class="btn btn-default btn-xs pull-right", role="button",
               tags$i(class="glyphicon glyphicon-edit")
             ),
             a(href="", class="btn btn-default btn-xs pull-right", role="button",
               tags$i(class="glyphicon glyphicon-edit")
             )
         )
  )
}


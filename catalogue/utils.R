# <div class="col-xs-18 col-sm-4 col-md-3">
#   <div class="productbox">
#     <div class="imgthumb img-responsive">
#       <img src="http://lorempixel.com/250/250/business/?ab=1df">
#     </div>
#     <div class="caption">
#       <h5>Lorem ipsum dolor sit amet</h5>
#       <a href="#" class="btn btn-default btn-xs pull-right" role="button">
#       <i class="glyphicon glyphicon-edit"></i></a> <a href="#" class="btn btn-info btn-xs" role="button">Button</a> <a href="#" class="btn btn-default btn-xs" role="button">Button
#       </a>
#     </div>
#   </div>
# </div>

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


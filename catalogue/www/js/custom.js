$(function() {

  console.log("ready");
  
  $("#price_reset").click(function(){
    
    console.log("I'm reset price! you click me! ah?");
    
    var slider = $("#price_range").data("ionRangeSlider");
    
    slider.update({ from: 0, to: slider.options.max });
    
    
  });
  
  
   $('body').on('click', '.prodbox', function() {
      
      console.log("I'm product! you click me! ah?");
      
      console.log($(this).attr("id"));
      
      Shiny.onInputChange("clicked", true);
      Shiny.onInputChange("prod_id", $(this).attr("id"));
      $(window).scrollTop(0);
      
    });
    
    // Reset click input value when user changes tab.
    // This makes Shiny observer to observe for changes more "eagerly".
    $('body').on('click', '#tabset li', function() {
      Shiny.onInputChange('clicked', false);
    });
  
  $("#viewas").click(function(){
    
    console.log("I'm viewass btn! you click me! ah?");
    console.log($("#viewas .active > input").attr("value"));    
    Shiny.onInputChange("viewas", $("#viewas .active > input").attr("value"));
    
  });
  
});
$(function() {
  
  function validateEmail(email) {
    var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
    return re.test(email);
  }
  
  $("#checkout").click(function() {
     
   console.log("I'm checkout button! you click me! ah?");
   
   console.log($(this));
   
   swal({
     title: "Are you sure you want to checkout?",
     text: "You will need to put your email address to send the information.",
     type: "warning",
     showCancelButton: true,
     type: "input",
     inputType: "email",
     confirmButtonColor: "#3FB618",
     confirmButtonText: "Yes, I want checkout!",
     cancelButtonText: "No, I want continue shopping!",
     closeOnConfirm: false,
     closeOnCancel: false
   }, function(email){
     console.log(email);
     console.log(email.length);
     console.log(1);
     if (email) {
       if (validateEmail(email)) {
         console.log(3);
         swal("Nice!", "Your awesome order was created.", "success");
       } else {
         console.log(4);
         swal("Mmm!", "Your emails don't seems like an email.", "warning");
       }
     } else {
       swal("Ok!", "Keep looking our products :)", "info");
     }
   });
    
  });
  
});
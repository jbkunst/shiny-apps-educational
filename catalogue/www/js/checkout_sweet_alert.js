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
     if (email === "") {
       swal.showInputError("You need to type an email to checkout!");
       return false;
     }
     if (email) {
       if (validateEmail(email)) {
         swal("Nice!", "Your awesome order was created.", "success");
       } else {
          swal.showInputError("Mmm. Is it your email an email?");
          return false;
       }
     } else {
       swal("Ok!", "Keep looking our products :)", "info");
     }
   });
    
  });
  
});
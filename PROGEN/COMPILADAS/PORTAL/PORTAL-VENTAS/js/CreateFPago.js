if (
  window.localStorage.getItem("FoPago") !== undefined &&
  window.localStorage.getItem("FoPago")
) {

  var data = localStorage.getItem("FoPago");
  $("#inputCondicion").empty();
  $("#inputCondicion").append(data);
} else {
 
  $.ajax({
    type: "POST",
    url: "../../controller/read/ConsFormaPago.php",

    // url: "../../controller/api/ws_verify_FoPago.php",
  })
    .done(function (data) {
      // console.log(data);
      if(data==1){

      }else{
        localStorage.setItem("FoPago", data);
        $("#inputCondicion").empty();
        $("#inputCondicion").append(data);
      }
   
    })
    .fail(function () {
      // alert("Hubo un errror al cargar las Formas de Pago");
    });
}

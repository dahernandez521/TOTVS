// $("#coverScreen").show();
// var array = localStorage.getItem("Carrito-" + InfoClien[0]);

// $.ajax({
//   type: "POST",
//   url: "../../controller/read/ConsLocalCarrito.php",
// })
//   .done(function (data) {
//     LLenarCarrito(data);
//   })
//   .fail(function () {
//     // alert("Hubo un errror al cargar los Carritos");
//   });

function LLenarCarrito(data) {
  // console.log(data);
  $(".odd").remove();
  // $("#divTabla").empty();
  // $("#divTabla").append(data);

  ConfigTableCoti();
  $("#coverScreen").hide();
}

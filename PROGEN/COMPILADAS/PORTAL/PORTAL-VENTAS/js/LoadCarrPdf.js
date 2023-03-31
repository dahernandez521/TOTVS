function LoadCarrito() {
  $.ajax({
    type: "POST",
    url: "../../controller/read/ConsCarrPdf.php",
  })
    .done(function (data) {
      data = data.split("??");
      data = data[0];

      if (data != "") {
        $("#tbody").empty();
        $("#tbody").append(data);
      }
    })
    .fail(function () {
      // alert("Hubo un errror al cargar el Carrito");
    });

}

LoadCarrito();
console.log("==============pdf==================")

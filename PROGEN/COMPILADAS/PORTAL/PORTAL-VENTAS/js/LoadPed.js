if (window.localStorage) {
  if (
    window.localStorage.getItem("PedidosClien") !== undefined &&
    window.localStorage.getItem("PedidosClien")
  ) {
    var array = localStorage.getItem("PedidosClien");

    $.ajax({
      type: "POST",
      url: "../../controller/read/ConsLocalPedi.php",
      data: { array: array },
    })
      .done(function (data) {
        LLenarPedido(data);
      })
      .fail(function () {
        alert("Hubo un errror al cargar los productos");
      });
  } else {
    $("#coverScreen").hide();
  }
}

$("#buttonLoad").click(function () {
  Inactividad()
  $("#coverScreen").show();

  $("#buttonLoad").attr("disabled", "disabled");
  FecInic = $("#FecInic").val();
  FecFini = $("#FecFini").val();

  var datos = "FecInic=" + FecInic + "&FecFini=" + FecFini;

  $.ajax({
    type: "POST",
    url: "../../controller/read/ConsPedi.php",
    data: datos,
  })
    .done(function (data) {
      $.ajax({
        type: "POST",
        url: "../../controller/read/CreaLocalPedi.php",
      })
        .done(function (data) {
          localStorage.setItem("PedidosClien", data);
        })
        .fail(function () {
          alert("Hubo un errror al cargar los pedidos");
        }); 

      LLenarPedido(data);
    })
    .fail(function () {
      alert("Hubo un errror al cargar los pedidos");
    });
});

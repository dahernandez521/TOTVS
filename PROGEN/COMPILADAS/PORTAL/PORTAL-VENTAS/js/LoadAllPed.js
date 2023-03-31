if (window.localStorage) {
  if (
    window.localStorage.getItem("AllPedidos") !== undefined &&
    window.localStorage.getItem("AllPedidos")
  ) {
    var array = localStorage.getItem("AllPedidos");

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
  $("#coverScreen").show();

  $("#buttonLoad").attr("disabled", "disabled");
  FecInic = $("#FecInic").val();
  FecFini = $("#FecFini").val();

  var datos = "FecInic=" + FecInic + "&FecFini=" + FecFini + "&Cliente=" + 0;

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
          localStorage.setItem("AllPedidos", data);
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

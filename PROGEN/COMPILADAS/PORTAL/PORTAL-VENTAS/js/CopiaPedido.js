$("#coverScreen").show();
$.ajax({
  type: "POST",
  url: "../../controller/read/ConsCopiaPedido.php",
})
  .done(function (data) {
    if (data != "") {
      $("#tbody").empty();
      $("#tbody").append(data);
      $(".Val-Pre").css("display", "none"); // oculta los campos de datos originales
      ValDesc();
      LoadModalCopPed();
    }

    const table = document.getElementById("tablaprueba");
    const rowCount = table.rows.length;

    for (var vd = 1; vd <= rowCount - 1; vd++) {
      $("#td" + vd + "").append(
        '<datalist id="produc-list' + vd + '" class="lista_prod">  </datalist>'
      );
    }
    ajax_pro();
  })
  .fail(function () {
    // alert("Hubo un errror al cargar la Copia del Pedido");
  });

function LoadModalCopPed() {
  $.ajax({
    type: "POST",
    url: "../../controller/read/ModalCopPed.php",
  })
    .done(function (data) {
      //  console.log(data);

      $("#ModalPedido").empty();
      $("#ModalPedido").append(data);

      const tablea = document.getElementById("tablaprueba");
      const rowCounta = tablea.rows.length;

      for (var sd = 1; sd <= rowCounta - 1; sd++) {
        total(sd);
      }
    })
    .fail(function () {
      // alert("Hubo un errror al cargar los precios");
    });
}

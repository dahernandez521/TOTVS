$(window).on("load", function () {
  $("#coverScreen").hide();
  $(".loader-text").hide();

  $(".Clien").click(function () {
    $("#buttonGenerar").removeAttr("disabled");
  });

  $("#buttonGenerar").click(function () {
    if( $('input:radio[name=clien]').is(':checked') ) {
      alert('Seleccionado');
  }else{
    alert('fraude');
  }
    if (
      window.localStorage.getItem("Maestro_productos") !== undefined &&
      window.localStorage.getItem("Maestro_productos")
    ) {
      localStorage.removeItem("Maestro_productos");
    }

    ValSel = $("input:radio[name=clien]:checked").val();
    ValSel = ValSel.split("??");
    Cliente = ValSel[0];
    Lprec = ValSel[1];

    var datos = "Cliente=" + Cliente + "&Lpreci=" + Lprec;

    $("#buttonGenerar").attr("disabled", "disabled");
    $(".Clien").attr("disabled", "disabled");
    $(".btn").attr("disabled", "disabled");
    $("#coverScreen").show();
    $(".loader-text").show();

    $.ajax({
      type: "POST",
      url: "../../controller/read/ConsProd.php",
      data: datos,
    })
      .done(function (data) {
        localStorage.setItem("Maestro_productos", data);
        location.href =
          "http://localhost/GitHub/PORTAL-VENTAS/VERSION_1/view/cliente/Crear_pedido";
      })
      .fail(function () {
        alert("Hubo un errror al cargar los productos");
      });
  });
});

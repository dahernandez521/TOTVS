$(window).on("load", function () {
  $("#coverScreen").hide();
  $(".loader-text").hide();
});

$("#buttonGenerar").removeAttr("disabled");
$("#buttonConsultar").removeAttr("disabled");
$("#buttonProductos").removeAttr("disabled");

$("#buttonGenerar").click(function () {
  ValidarCliente("Crear_pedido");
});

$("#buttonConsultar").click(function () {
  ValidarCliente("Consultar_Pedidos");
});

$("#buttonProductos").click(function () {
  ValidarCliente("VerProductos");
});

function ValidarCliente($param) {

  Inactividad();
  if ($("input:radio[name=clien]").is(":checked")) {
    ValSel = $("input:radio[name=clien]:checked").val();
    ValSel = ValSel.split("??");
    Cliente = ValSel[0];
    Lprec = ValSel[1];
    Loja = ValSel[2];

    var datos = "Cliente=" + Cliente + "&Lpreci=" + Lprec + "&Loja=" + Loja;

    $("#buttonGenerar").attr("disabled", "disabled");
    $(".Clien").attr("disabled", "disabled");
    $(".btn").attr("disabled", "disabled");
    $("#coverScreen").show();

    // if (
    //   window.localStorage.getItem("Maestro_productos") !== undefined &&
    //   window.localStorage.getItem("Maestro_productos")
    // ) {
    //   //  si pasa normal
    //   console.log("normal")
    //   $.ajax({
    //     type: "POST",
    //     url: "../../controller/read/NewClien.php",
    //     data: datos,
    //   })
    //     .done(function (data) {
    //       // console.log(data);
    //       $("#coverScreen").hide();
    //        location.href = $param;
    //     })
    //     .fail(function () {});
      
    // } else {
      $.ajax({
        type: "POST",
        url: "../../controller/read/ConsProd.php",
        data: datos,
      })
        .done(function (datas) {
          data = datas.split("??");
          if (data[0] != "0") {
            
            localStorage.removeItem("PedidosClien");
            localStorage.setItem("Maestro_productos", data[0]);
            localStorage.setItem("RefCruz_productos", "Success"/*data[1]*/);
            localStorage.setItem("Modalidades", data[2]);
            localStorage.setItem("Clien", data[4]);
            $("#coverScreen").hide();
              location.href = $param;

          }else{
            $("#coverScreen").hide();
            Swal.fire({
              title: "Error",
              text: "No pudimos conectar los productos, logueate nuevamente. Si el problema persiste contacta al administrador",
              icon: "error",
              timer: 5000,
            }).then(() => {});
          }
        })
        .fail(function () {});
    // }

    
  } else {
    Swal.fire({
      title: "Invalido",
      text: "Por favor seleccione un cliente para continuar",
      icon: "error",
      timer: 3000,
    }).then(() => {});
  }
}

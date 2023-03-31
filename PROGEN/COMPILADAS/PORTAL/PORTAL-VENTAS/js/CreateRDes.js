if (
  window.localStorage.getItem("ReNego") !== undefined &&
  window.localStorage.getItem("ReNego")
) {
} else {
  $.ajax({
    type: "POST",
    url: "../../controller/api/ws_verify_ReNego.php",

    // url: "../../controller/api/ws_verify_FoPago.php",
  })
    .done(function (data) {
      try {
        if(data.length>1){
          localStorage.setItem("ReNego", "Success Load Reg Neg");
          }
        // localStorage.setItem("ReNego", data);
      
      } catch (err) {
      
        Swal.fire({
          title: "¡Un error ha ocurrido!",
          html: err+" <br> Se generara limpieza en cache, por favor seleccionar nuevamente el cliente. <br> si el problema persiste contacte al administrador",
          icon: "warning",
        }).then((result) => {
          localStorage.clear();
          location.href='Consultar_Clientes';
        });
      
      }
    })
    .fail(function () {
      // alert("Hubo un errror al cargar las Formas de Pago");
    });
}

if (
  window.localStorage.getItem("ImpIVA") !== undefined &&
  window.localStorage.getItem("ImpIVA")
) {
  $("#Imp").hide();
} else {
  $.ajax({
    type: "POST",
    url: "../../controller/api/ws_verify_ImpIVA.php",
  })
    .done(function (data) {

      try {
        if(data.length>1){
        localStorage.setItem("ImpIVA", "Success Load Imp Iva");
        }
        $("#Imp").hide();
      
      } catch (err) {
      
        Swal.fire({
          title: "¡Un error ha ocurrido!",
          html: err+" <br> Se generara limpieza en cache, por favor seleccionar nuevamente el cliente. <br> si el problema persiste contacte al administrador",
          icon: "warning",
        }).then((result) => {
          $("#Imp").hide();
          localStorage.clear();
          location.href='Consultar_Clientes';
        });
      
      }


    })
    .fail(function () {
      // alert("Hubo un errror al cargar los Impuestos");
    });
}

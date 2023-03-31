$(window).on("load", function () {
  $("#miimg").click(function () {
    alert("Please");
  });

  $("#Refresh").click(function () {
    $("#ScreenProd").show();

    $.ajax({
      type: "POST",
      url: "../../controller/read/Refresh.php",
    })
      .done(function (datas) {
        data = datas.split("??");
        if (data[0] != "0") {
          console.log(data);
          localStorage.removeItem("PedidosClien");
          localStorage.setItem("Maestro_productos", data[0]);
          localStorage.setItem(
            "RefCruz_productos",
            "Success Refresh" /*data[1]*/
          );

          var array = localStorage.getItem("Maestro_productos");

          $.ajax({
            type: "POST",
            url: "../../controller/read/ConsProdGuar.php",
            data: { array: array,refresh: 1},
          })
            .done(function (dataX) {
              dataX = dataX.split("??");
              // console.log(dataX[1]);
              localStorage.setItem("Lis_Prod", dataX[0]);
               location.reload();
            })
            .fail(function () {
              // alert("Hubo un errror al cargar los productos");
            });

          $("#ScreenProd").hide();
          
        } else {
          $("#ScreenProd").hide();
          Swal.fire({
            title: "Error",
            text: "No pudimos conectar los productos, logueate nuevamente. Si el problema persiste contacta al administrador",
            icon: "error",
            timer: 5000,
          }).then(() => {});
        }
      })
      .fail(function () {});
  });
});

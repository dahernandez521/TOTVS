function LoadCarrito() {
  // console.log("voy a entrar al ajax de consultar mi cotización");
  $.ajax({
    type: "POST",
    url: "../../controller/read/ConsDetCarri.php",
  })
    .done(function (data) {
      data = data.split("??");
      data = data[0];
      // console.log("volvi del ajax de mi cotiazacion");
      // console.log(data  );
      if (data != "") {
        // console.log(data);
        $("#tbody").empty();
        $("#tbody").append(data);
        $(".Val-Pre").css("display", "none"); // oculta los campos de datos originales
        ValDesc();
        LoadModalCarrPed();
      }

      const table = document.getElementById("tablaprueba");
      const rowCount = table.rows.length;

      for (var vd = 1; vd <= rowCount - 1; vd++) {
        $("#td" + vd + "").append(
          '<datalist id="produc-list' +
            vd +
            '" class="lista_prod">  </datalist>'
        );
        total(vd);
      }
      ajax_pro();

      $("#coverScreenshop").hide();
    })
    .fail(function () {
      console.log('Failed to')
      // alert("Hubo un errror al cargar el Carrito");
    });

  $("#coverScreen").hide();
}

LoadCarrito();


function LoadModalCarrPed() {
  $.ajax({
    type: "POST",
    url: "../../controller/read/ModalCarrProd.php",
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

function updateCarrito() {
  try {
    $.ajax({
      type: "POST",
      url: "../../controller/read/LoadCliePed.php",
    })
      .done(function (data) {
        InfoClien = data.split("??");
        Clien = InfoClien[0];
        Contador = 0;
        const table = document.getElementById("tablaprueba");
        const rowCount = table.rows.length;

        localStorage.removeItem("Carrito-" + InfoClien[0]);

        Carrito = {
          Client: InfoClien[0],
          Items: [],
        };

        Carrito = JSON.stringify(Carrito);
        localStorage.setItem("Carrito-" + InfoClien[0], Carrito);

        for (var cont = 1; cont <= rowCount + 1000; cont++) {
          if (Contador == rowCount) {
            break;
          }

          if ($("#inputProducto" + cont + "").length) {
            prod = $("#inputProducto" + cont + "").val();
            cant = parseInt($("#inputCantidad" + cont + "").val());
            Obs = $("#inputObservacion" + cont + "").val();

            if (cant > 0) {
              var array = localStorage.getItem("Carrito-" + Clien);

              array = JSON.parse(array);

              var ItemsPed = {
                clien: Clien,
                Producto: prod,
                Cantidad: cant,
                Observacion: Obs,
              };

              array.Items.push(ItemsPed);

              array = JSON.stringify(array);

              localStorage.setItem("Carrito-" + Clien, array);
            }
            Contador++;
          }
        }
      })
      .fail(function () {
        // alert("Hubo un errror al modificar el  carrito");
      });
  } catch (error) {}
}

function UpdateFormcarrito(Clien, cont) {}

function CreaCarrito() {
  try {
    $.ajax({
      type: "POST",
      url: "../../controller/read/LoadCliePed.php",
    })
      .done(function (data) {
        InfoClien = data.split("??");

        if (
          window.localStorage.getItem("Carrito-" + InfoClien[0]) !==
            undefined &&
          window.localStorage.getItem("Carrito-" + InfoClien[0])
        ) {
        } else {
          Carrito = {
            Client: InfoClien[0],
            Items: [],
          };

          var ItemsPed = {
            Producto: null,
            Cantidad: null,
            Observacion: null,
          };

          Carrito = JSON.stringify(Carrito);
          localStorage.setItem("Carrito-" + InfoClien[0], Carrito);
        }
      })
      .fail(function () {
        // alert("Hubo un errror al cargar el carrito");
      });
  } catch (error) {}
}

CreaCarrito();

function carrito(cont) {
  prod = $("#prod" + cont + "").val();
  cant = parseInt($("#cant" + cont + "").val());
  Obs = $("#Obs" + cont + "").val();
  var array = localStorage.getItem("Carrito-" + InfoClien[0]);

  array = JSON.parse(array);

  var ItemsPed = {
    clien: InfoClien[0],
    Producto: prod,
    Cantidad: cant,
    Observacion: Obs,
  };

  array.Items.push(ItemsPed);

  array = JSON.stringify(array);

  localStorage.setItem("Carrito-" + InfoClien[0], array);
}

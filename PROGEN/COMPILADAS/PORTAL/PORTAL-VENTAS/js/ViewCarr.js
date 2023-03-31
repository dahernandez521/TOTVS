a =
  '<a class="dropdown-item" href="#" onclick="PedCarr()">' +
  '<label id="cantcar" style="  background-color: yellow;  border-radius: 100%;  z-index: 999;  min-width: 30px;  text-align: center;  font-size: 12pt;  font-weight: bold;  position: absolute;  margin-left: 45px;  min-height: 27px;  margin-top: -5px;">0</label>' +
  '<img src="../../img/carrito-de-compras.png" alt=""  id="carrito"' +
  'style="  width: 60px;float: left;"></a>';
  
  $("#MiCar").empty();
  $("#MiCar").append(a);

window.setInterval(function () {
  try {
    $.ajax({
      type: "POST",
      url: "../../controller/read/LoadCliePed.php",
    })
      .done(function (data) {
        InfoClien = data.split("??");

        var array = localStorage.getItem("Carrito-" + InfoClien[0]);
// console.log(array)
        consCar(InfoClien[0], array);
      })
      .fail(function () {
        // alert("Hubo un errror al cargar el carrito");
      });
  } catch (error) {
    console.log(error);
  }
}, 5000);

function consCar(Clien, array) {
  try {
    $.ajax({
      type: "POST",
      url: "../../controller/read/ConsDetCarri.php",
      data: { Clien: Clien, array: array,Tipo:1 },
    })
      .done(function (Det) {
        //  console.log(Det);
        Deta = Det.split("??");
        Deta = Deta[1];
        
        // if (Deta > 1) {
          // if ($("#carrito").length <= 0) {
            $("#MiCar").empty();
            $("#MiCar").append(a);
          // }
          // {
            $("#cantcar").empty();
            $("#cantcar").append(Deta - 1);
          // }
        // } else {
        //   $("#cantcar").empty();
        //   $("#MiCar").empty();
        // }
      })

      .fail(function () {
        // alert("Hubo un errror al cargar el carrito");
      });
  } catch (error) {}
}

console.time("CaPeido");
function ConsClien() {
  $.ajax({
    type: "POST",
    url: "../../controller/read/ConsClienGuar.php",
  })
    .done(function (data) {
      $(".lista_Clien").empty();
      $(".lista_Clien").append(data);
    })
    .fail(function () {
      // alert("Hubo un errror al cargar los Clientes");
    });
}

//ConsClien(); //se desabilita la consulta de clientes a peticion del cliente

// $("#NumIdenTwo").change(function () {

function SelClien() {
  ClAnti = $("#inputIdCliente").val();
  ClNuevo = $("#NumIdenTwo").val();

  if ($.trim(ClAnti) != $.trim(ClNuevo)) {
    $("#coverScreen").show();

    Observa = $("#Descripcion").val();
    var datos =
      "ClAnti=" + ClAnti + "&ClNuevo=" + ClNuevo + "&Observa=" + Observa;

    if (ClNuevo > 0 && ClNuevo != ClAnti) {
      $.ajax({
        type: "POST",
        url: "../../controller/read/LoadClieCabeza.php",
        data: datos,
      })
        .done(function (data) {
          $("#CabezaPedi").empty();
          $("#CabezaPedi").append(data);
          // ConsClien();
          Load_DiviPola();
          LoadModalidades();
          ValDesc();
          $("#coverScreen").hide();
        })
        .fail(function () {
          // alert("Hubo un errror al cargar el Cliente");
        });
    } else {
      $("#NumIdenTwo").val(ClAnti);
    }
  }
  // $("#coverScreen").hide();
}

function LoadModalidades() {
  if (window.localStorage) {
    if (
      window.localStorage.getItem("Modalidades") !== undefined &&
      window.localStorage.getItem("Modalidades")
    ) {
      var array = localStorage.getItem("Modalidades");
      // array = JSON.parse(array);

      $.ajax({
        type: "POST",
        url: "../../controller/read/Modalidades.php",
        data: { array: array },
      })
        .done(function (data) {
          // console.timeEnd("CaPeido");

          $("#Modalidad").empty();
          $("#Modalidad").append(data);
        })
        .fail(function () {
          // alert("Hubo un errror al cargar los productos");
        });
    } else {
      MaestrosProductos();
    }
  }
}
LoadModalidades();

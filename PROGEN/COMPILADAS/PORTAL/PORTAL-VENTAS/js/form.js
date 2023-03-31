function CrearFila() {
  ajax_pro();
  document.getElementById("tbody").innerHTML = "<tr id=tr1></tr>";
  document.getElementById("tr1").innerHTML =
    '<td><button type="button"  id="delete1" class="form-control"  onclick="eliminarFilaSele(1)" style="border: none"><img src="../../img/menos.png" alt="borrar" width="20px"></button></td>' +
    '<td width="18%"><input type="text" id="inputProducto1" autocomplete="off" class="form-control producs" required onkeyup="SelProd(1)"  list="produc-list1" style="font-size:12px;"></td>' +
    '<datalist id="produc-list1" class="lista_prod">  </datalist>' +
    '<td width="18%"><input type="text"   id="inputDescripcion1" disabled class="form-control" style="font-size:12px;"></td>' +
    '<td width="15%"><input type="text"   id="inputObservacion1" autocomplete="off" class="form-control" style="font-size:12px;"></td>' +
    '<td width="5%"><input type="number" value="0" id="inputCantidad1" onchange="ValiCamp(1, 1)" onkeyup="total(1)" class="form-control" style="font-size:12px;"></td>' +
    '<td><input style="text-align:right;" type="text" value="0" id="inputPrecio1" disabled   onchange="ValiCamp(2, 1)" onkeyup="total(1)" class="form-control" style="font-size:12px;"></td>' +
    '<td class="Val-Pre"><input type="number" value="0" id="inputPrecio1-ori" disabled   class="form-control" style="font-size:12px;"></td>' +
    // '<td class="tides"> <select name="tip_de" id="tides1" onchange="total(1)" class="form-control ">' +
    // '    <option value="V">Valor</option>' +
    // '    <option value="P">Porcentaje</option>' +
    // "</select> </td>" +
    '<td class="Val-Pre"><input type="number" value="0" disabled id="inputTotal1-ori"  class="form-control val-tot-ori"  style="font-size:12px;"></td>' +
    '<td><input style="text-align:right;" type="text" value="0" disabled id="inputTotal1"  class="form-control val-tot"  style="font-size:12px;"></td>' +
    '<td><button type="button" class="btn" data-bs-toggle="modal" data-bs-target="#Imp1"><img src="../../img/lupa.png" alt="ver" width="20px"></button>' +
    '<img src="../../img/stockno.png" title="Stock: 0" alt="ver" id="stock1" width="20px"></td> ' +
    '</tr>';

  contador = 1;
  ModalPedido(contador);
  ValDesc(); //funcion para validar si se visualzian los descuentos
  ajax_pro();
}

function validar(NewCon) {
  const table = document.getElementById("tablaprueba");
  const rowCount = table.rows.length;

  if (contador > 0) {
    var variable = $("#inputProducto" + NewCon + "").val();
    if (variable == "") {
      Swal.fire({
        title: "Linea vacia",
        text: "debe digitar el producto anterior",
        icon: "error",
        timer: 3000,
      });
    }
  } else {
    contador = 1;
  }

  for (var v = 1; v <= rowCount - 1; v++) {
    if ($("#delete" + v).length) {
      contador = v + 1;
    } else {
      contador = v;
      break;
    }
  }
}

// VALIDAR QUE LA LINEA ACTUAL TENGA DATOS ANTES DE INGRESAR UNA NUEVA BY DUVAN
const agregarFila = () => {
  NewCon = contador;

  var cam = 3;
  var id = NewCon;
  var result1 = 0;
  var result2 = 0;

  for (var i = 1; i <= id; i++) {
    result1 = ValiCamp(1, i);
    if (result1 == 999) {
      break;
    }
  }
  var id = NewCon;

  for (var p = 1; p <= id; p++) {
    result2 = ValiCamp(2, p);
    if (result2 == 999) {
      break;
    }
  }

  if (result1 != 999 && result2 != 999) {
    validar(NewCon);
    NewCon = contador - 1;

    if (NewCon < contador) {
      $("#tablaprueba tbody").append(
        '<tr id="tr' +
          contador +
          '">' +
          '<td><button type="button"  id="delete' +
          contador +
          '" class="form-control"  onclick="eliminarFilaSele(' +
          contador +
          ')" style="border: none"><img src="../../img/menos.png" alt="borrar" width="20px"></button></td>' +
          '<td width="18%" id="td' +
          contador +
          '"></td>' +
          '<td width="18%"><input type="text" disabled id="inputDescripcion' +
          contador +
          '" class="form-control" style="font-size:12px;"></td>' +
          '<td><input type="text" autocomplete="off" id="inputObservacion' +
          contador +
          '" class="form-control" style="font-size:12px;"></td>' +
          '<td><input type="number" value="0" placeholder="0" style="font-size:12px;" id="inputCantidad' +
          contador +
          '" onchange="ValiCamp(1,' +
          contador +
          ')"' +
          ' onkeyup="total(' +
          contador +
          ')" class="form-control"></td>' +
          '<td><input type="text" style="text-align:right;" value="0"  disabled placeholder="0" style="font-size:12px;" id="inputPrecio' +
          contador +
          '" onchange="ValiCamp(2,' +
          contador +
          ')"' +
          ' onkeyup="total(' +
          contador +
          ')" class="form-control"></td>' +
          '<td class="Val-Pre"><input type="number" value="0" style="font-size:12px;"  disabled placeholder="0" id="inputPrecio' +
          contador +
          '-ori")" class="form-control Val-Pre"></td>' +
          // '<td class="tides inputtides"> <select name="tip_de" id="tides' +
          // contador +
          // '" onchange="total(' +
          // contador +
          // ')" class="form-control">' +
          // '    <option value="V">Valor</option>' +
          // '    <option value="P">Porcentaje</option>' +
          // "</select> </td class='tides'>" +
          // '<td class="tides inputtides"><input type="number" disabled value="0" placeholder="0" style="font-size:12px;" id="inputDescuento' +
          // contador +
          // '" onkeyup="total(' +
          // contador +
          // ')" class="form-control"></td>' +
          // '<td class="tides "><input type="number" value="0" placeholder="0" disabled style="font-size:12px;" id="totDescuento' +
          // contador +
          // '" onkeyup="total(' +
          // contador +
          // ')" class="form-control desc-tot"></td>' +
          '<td class="Val-Pre"><input type="number" value="0" placeholder="0" disabled id="inputTotal' +
          contador +
          '-ori" class="form-control val-tot-ori"></td>' +
          '<td><input style="text-align:right;" type="text" value="0" placeholder="0" disabled style="font-size:12px;" id="inputTotal' +
          contador +
          '" class="form-control val-tot"></td>' +
          '<td><button type="button" class="btn" data-bs-toggle="modal" data-bs-target="#Imp' +
          contador +
          '"><img src="../../img/lupa.png" alt="ver" width="20px"></button> '+
          
              '<img src="../../img/stockno.png" title="Stock: 0" alt="ver" id="stock'+contador +'" width="20px"></td> ' +
    '</tr>'
      );

      document.getElementById("td" + contador).innerHTML =
        '<input  style="font-size:12px;" type="text" autocomplete="off" id="inputProducto' +
        contador +
        '" class="form-control producs" required  onkeyup="SelProd(' +
        contador +
        ')"  list="produc-list' +
        contador +
        '"></input>' +
        '<datalist id="produc-list' +
        contador +
        '" class="lista_prod">  </datalist>';
      ajax_pro(1);
      ModalPedido(contador);
    }
  }

  ValDesc(); //funcion para validar si se visualzian los descuentos
};

function eliminarFilaSele($num) {
  const table = document.getElementById("tablaprueba");

  $("#tr" + $num).remove();
  $("#Imp" + $num).remove();
  const rowCount = table.rows.length;

  if (rowCount == 1) {
    CrearFila();
  }

  TotFinal();
}

function eliminarFillasAll() {
  $("tbody").empty();
  $("#ModalPedido").empty();

  CrearFila();

  TotFinal();
}

const eliminarFila = () => {
  const table = document.getElementById("tablaprueba");
  const rowCount = table.rows.length;
  var lon = rowCount;

  if (rowCount <= 1) swal("No es posible eliminar el encabezado!", "", "error");
  else {
    table.deleteRow(rowCount - 1);
    con = rowCount - 1;
    $("#Imp" + con).remove();
    contador = contador - 1;
    if (lon == 2) {
      CrearFila();
    }
  }

  TotFinal();
};

function ValDesc() {
  $(".Val-Pre").css("display", "none"); // oculta los campos de datos originales

  $.ajax({
    type: "POST",
    url: "../../controller/read/VisiDesc.php",
  })
    .done(function (data) {
      if (data == 1) {
        $("#DivTab").removeClass("col-12");
        $("#DivTab").addClass("col-4");
        $(".tides").css("display", "none");
      }
    })
    .fail(function () {
      // alert("Hubo un errror al cargar los precios");
    });
}

function CalcuDesGene() {
  const table = document.getElementById("tablaprueba");
  const rowCount = table.rows.length;

  for (var pd = 1; pd <= rowCount - 1; pd++) {
    ValProd = $("#inputPrecio" + pd + "-ori").val();
    ValFina = 0;
    ValDes = 0;
    vadesPro = 0;
    ValDesPro = 0;

    // Descuento General
    vades = $("#DesGene").val();
    ValDes = ValProd * (vades / 100);
    ValFina = ValProd - ValDes;

    $("#AllDesc" + pd + "").val(redondearDecimales(ValDes));

    // Descuento x Producto
    vadesPro = $("#inputDescuento" + pd + "").val();
    ValDesPro = ValFina * (vadesPro / 100);

    // asignacion de valor final

    ValFina = ValFina - ValDesPro;

    // ValFina = redondearDecimales(ValFina);

    $("#inputPrecio" + pd + "").val(new Intl.NumberFormat('es-CO').format(parseFloat(ValFina).toFixed(3)));

    total(pd);
  }
}

function CalcuDesGeneProd(pd) {
  // se quito esto
}

function ModalPedido(id) {
  $("#ModalPedido").append(
    '<div class="modal fade" id="Imp' +
      id +
      '"  tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">' +
      '<div class="modal-dialog modal-lg">' +
      '<div class="modal-content">' +
      '<div class="modal-header">' +
      '<h5 class="modal-title" style="color:black;" id="exampleModalLabel">Detalle de Impuestos</h5>' +
      '<button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>' +
      "</div>" +
      '<div class="modal-body">' +
      '<div class="row">' +
      '<div class="form-group row p-3">' +
      '<table class="table table-bordered">' +
      "<thead>" +
      "<tr>" +
      "<th>Impuesto</th>" +
      "<th>Descripción</th>" +
      "<th>Valor %</th>" +
      "<th>Valor</th>" +
      "</tr>" +
      "</thead>" +
      "<tbody>" +
      "<tr>" +
      "<td id='CodImp" +
      id +
      "'></td>" +
      "<td id='NomImp" +
      id +
      "'></td>" +
      '<td> <input type="number" style="border:none;" required disabled value="0" id="PorImp' +
      id +
      '" autocomplete="off"></td>' +
      '<td><input type="text" style="border:none; text-align:right;" disabled value="0" id="TotImp' +
      id +
      '" autocomplete="off" class="TotImpuIva"></td>' +
      "</tr>" +
      "</tbody>" +
      "</table>" +
      '<div class="form-group row">' +
      '<label for="delim" class="col-sm-3 col-form-label">Descuento %</label>' +
      '<div class="col-sm-7">' +
      '<input type="number" required disabled value="0" id="inputDescuento' +
      id +
      '" autocomplete="off" class="form-control">' +
      "</div>" +
      '<label for="delim" class="col-sm-3 col-form-label">Val Descu</label>' +
      '<div class="col-sm-7">' +
      '<input type="text" required disabled value="0" id="totDescuento' +
      id +
      '" autocomplete="off" class="form-control desc-tot">' +
      "</div>" +
      "</div>" +
      "</div>" +
      "</div>" +
      '<div class="modal-footer">' +
      '<button type="button" class="btn btn-primary" data-bs-dismiss="modal">Ocultar</button> ' +
      "</div>" +
      "</div>" +
      "</div>" +
      "</div>"
  );
}

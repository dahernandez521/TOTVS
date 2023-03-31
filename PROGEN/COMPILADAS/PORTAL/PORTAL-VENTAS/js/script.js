
if (window.localStorage) {
  if (
    window.localStorage.getItem("Maestro_productos") !== undefined &&
    window.localStorage.getItem("Maestro_productos")
  ) {
    var array = localStorage.getItem("Maestro_productos");

    $.ajax({
      type: "POST",
      url: "../../controller/read/ConsProdGuar.php",
      data: { array: array },
    })
      .done(function (data) {})
      .fail(function () {
        alert("Hubo un errror al cargar los productos");
      });
  } else {
    // console.log("Maestro_productos no existe en localStorage!!");
    MaestrosProductos();
  }
}

function MaestrosProductos() {
  $.ajax({
    type: "POST",
    url: "../../controller/read/ConsProd.php",
  })
    .done(function (data) {
      data = data.split("??");
      if(data[0]!='0'){
      localStorage.setItem("Maestro_productos", data[0]);
      localStorage.setItem("RefCruz_productos", "Success"/*data[1]*/);
      localStorage.setItem("Modalidades", data[2]);
      }
    })
    .fail(function () {
      alert("Hubo un errror al cargar los productos");
    });
}

function DeleteMaestroProduct() {
  localStorage.removeItem("Maestro_productos");
  MaestrosProductos();
}

function ValiCamp(camp, id) {
  Inactividad();
  switch (camp) {
    case 1:
      if ($("#inputCantidad" + id + "").val() <= 0) {
        Swal.fire(
          {
            title: "¡Alerta!",
            text: "La cantidad debe ser mayor a 0",
            icon: "warning",
            timer: 3000,
          },
          function () {}
        );
        $("#inputCantidad" + id + "").val(0);
        camp = 999;
      }
      total(id);
      return camp;
      break;

    case 2:
      if ($("#inputPrecio" + id + "").val() <= 0) {
        Swal.fire(
          {
            title: "¡Alerta!",
            text: "El producto debe tener un valor $",
            icon: "warning",
            timer: 3000,
          },
          function () {}
        );

        $("#inputPrecio" + id + "").val(0);
        camp = 999;
      }
      total(id);
      ValiCamp(1, id);

      return camp;
      break;

    case 3:
      if (
        $("#inputPrecio" + id + "").val() <= 0 ||
        $("#inputCantidad" + id + "").val() <= 0
      ) {
        Swal.fire(
          {
            title: "¡Alerta!",
            text: "se deben asignar valor a todos los campos",
            icon: "warning",
            timer: 3000,
          },
          function () {}
        );

        camp = 999;
      }
      total(id);
      return camp;
      break;
  }
}

function redondearDecimales(numero) {
  decimales = 2;
  numeroRegexp = new RegExp("\\d\\.(\\d){" + decimales + ",}"); // Expresion regular para numeros con un cierto numero de decimales o mas

  if (numeroRegexp.test(numero)) {
    // Ya que el numero tiene el numero de decimales requeridos o mas, se realiza el redondeo
    return Number(numero).toFixed(decimales);
  } else {
    return Number(numero).toFixed(decimales) === 0 ? 0 : numero; // En valores muy bajos, se comprueba si el numero es 0 (con el redondeo deseado), si no lo es se devuelve el numero otra vez.
  }
}

function total(id) {
  // const formatterPeso = new Intl.NumberFormat("en-US", {
  //   style: "currency",
  //   currency: "USD",
  //   minimumFractionDigits: 0,
  // });

  const formatterPeso = new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    minimumFractionDigits: 0
  })

  can = 0;
  val = 0;
  valProd = 0;
  ValFinal = 0;
  Desxpro = 0;
  decimales=2
  Precc=$("#inputPrecio" + id + "").val()
  Press=$("#inputPrecio" + id + "-ori").val()
  if (Precc==null || Precc==undefined){
    Precc='0';
  }
  if (Press==null || Press==undefined){
    Press='0';
  }

  can = $("#inputCantidad" + id + "").val();
  val = parseFloat(((Precc).replace(/\./g,'')).replace(/\,/g,'.'));

  val2 =  (Press).replace(/\./g,'');
 


  tot = can * val;
  tot2 = can * val2;

  Iva = $("#PorImp" + id + "").val();
  ValIva = tot * (Iva / 100);

  $("#TotImp" + id + "").val(new Intl.NumberFormat('es-CO').format(parseFloat(ValIva).toFixed(decimales)));

  tides = $("#tides" + id + "").val();
  vades = $("#inputDescuento" + id + "").val();
  if (vades === undefined) {
    vades = 0;
  }

  tides = "P";
  // vades = 0;

  if (tides == "V") {
    tot = tot - vades;
    $("#totDescuento" + id + "").val(vades);
    $("#inputTotal" + id + "").val(tot);
    $("#inputTotal" + id + "-ori").val(tot2);
  } else if (tides == "P") {
    podes = tot2 * (vades / 100);
    // tot = tot - podes;

    // tot = redondearDecimales(tot);
    // console.log("id: "+id)
    // console.log("vades: "+vades)
    //   console.log("totDescuento: "+podes)
    //   console.log("inputTotal: "+tot)

    $("#totDescuento" + id + "").val(new Intl.NumberFormat('es-CO').format(parseFloat(podes).toFixed(decimales)));
    $("#inputTotal" + id + "").val(new Intl.NumberFormat('es-CO').format(parseFloat(tot).toFixed(decimales)));
    $("#inputTotal" + id + "-ori").val(tot2);
    

  }

  TotFinal();
}



function TotFinal() {
  var ValTota = 0;
  var OtrDesc = 0;
  var Subtota = 0;
  var Subtotaori = 0;
  var DescGene = 0;
  var Iva = 0;

  Nature=$.trim($("#Modalidad").val());

  if(Nature=="0300102"){
    $(".TotImpuIva").val(0)
  }



  $(".val-tot-ori").each(function () {
    Subtotaori += parseFloat((($(this).val().replace(/\./g,'')).replace(/\,/g,'.')));
  });
  Subtotaori=Subtotaori.toString()
  Subtotaori=parseFloat(Subtotaori.replace(/\,/g,'.'))


  $(".val-tot").each(function () {
    Subtota += parseFloat((($(this).val().replace(/\./g,'')).replace(/\,/g,'.')));
  });
  Subtota=Subtota.toString()
  Subtota=parseFloat(Subtota.replace(/\,/g,'.'))

  $(".desc-tot").each(function () {
    OtrDesc +=parseFloat((($(this).val().replace(/\./g,'')).replace(/\,/g,'.')));
  });
  OtrDesc=OtrDesc.toString()
  OtrDesc=parseFloat(OtrDesc.replace(/\,/g,'.'))


  $(".TotImpuIva").each(function () {
    Iva += parseFloat((($(this).val().replace(/\./g,'')).replace(/\,/g,'.')));
  });
  Iva=Iva.toString()
  Iva=parseFloat(Iva.replace(/\,/g,'.'))

  DescGene = $("#DesGene").val().replace(/\./g,'');
  DescGene = 0;
  if (DescGene == null) {
    DescGene = 0;
  }

  // Subtotaori = Subtota + OtrDesc;
  DescGene = Subtota * (DescGene / 100);

  PorDes = $("#DesGene").val();
  if (PorDes > 0) {
    DescGene = Subtotaori - Subtota;
  }

  if (OtrDesc > 0 && PorDes == 0) {
    ValTota = Subtotaori - OtrDesc - DescGene + Iva;
    TotDesc = OtrDesc;
  } else {
    ValTota = Subtotaori - DescGene + Iva;
    TotDesc = DescGene;
  }

  if (Subtota <= 0) {
    ValTota = 0;
    OtrDesc = 0;
    Subtota = 0;
    DescGene = 0;
    TotDesc = 0;
    Iva = 0;
  }

  // const formatterPeso = new Intl.NumberFormat("en-US", {
  //   style: "currency",
  //   currency: "USD",
  //   minimumFractionDigits: 0,
  // });

  const formatterPeso = new Intl.NumberFormat('es-CO', {
    style: 'currency',
    currency: 'COP',
    minimumFractionDigits: 0
  })

  $("#ValTota").val(  new Intl.NumberFormat('es-CO').format(parseFloat(ValTota).toFixed(decimales)));
  $("#ImpuesIva").val(  new Intl.NumberFormat('es-CO').format(parseFloat(Iva).toFixed(decimales)));
  $("#TotDesc").val(formatterPeso.format(0));
  $("#subtota").val(  new Intl.NumberFormat('es-CO').format(parseFloat(Subtotaori).toFixed(decimales)));
  $("#DescGene").val(  new Intl.NumberFormat('es-CO').format(parseFloat(TotDesc).toFixed(decimales)));





  if($(".CarAct").length){
    updateCarrito() 
  }
}

function ConfigTable() {
  var table = $("#example").DataTable({});

  //Creamos una fila en el head de la tabla y lo clonamos para cada columna
  $("#example thead tr").clone(true).appendTo("#example thead");

  $("#example thead tr:eq(1) th").each(function (i) {
    $(this).html('<input type="text" class="form-control" />');

    $("input", this).on("keyup change", function () {
      if (table.column(i).search() !== this.value) {
        table.column(i).search(this.value).draw();
      }
    });
  });

  $("#example").dataTable().fnDestroy();

  $("#example").dataTable({
    language: {
      sProcessing: "Procesando...",
      sLengthMenu: "Mostrar _MENU_ Registros",
      sZeroRecords: "No se encontraron resultados",
      sEmptyTable: "Ningún pedido disponible en esta Consulta",
      sInfo:
        "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
      sInfoEmpty: "Mostrando registros del 0 al 0 de un total de 0 registros",
      sInfoFiltered: "(filtrado de un total de _MAX_ registros)",
      sInfoPostFix: "",
      sSearch: "Buscar:",
      sUrl: "",
      sInfoThousands: ",",
      sLoadingRecords: "Cargando...",
      oPaginate: {
        sFirst: "Primero",
        sLast: "Último",
        sNext: "Siguiente",
        sPrevious: "Anterior",
      },
      oAria: {
        sSortAscending:
          ": Activar para ordenar la columna de manera ascendente",
        sSortDescending:
          ": Activar para ordenar la columna de manera descendente",
      },
      buttons: {
        copy: "Copiar",
        colvis: "Visibilidad",
      },
    },
  });
}


// function ConfigTableCoti() {

//   $("#Cotizacion").dataTable().fnDestroy();

//   $('#Cotizacion').dataTable({
//     "ajax": "getData.php",
//     "columns": [
//         { "data": "num" },
//         { "data": "MessageForNote" },
//         { "data": "cant" },
//         { "data": "date" },
//         { "data": "Usuario" },
//         { "data": "pedido" },
//         { "data": "pdf" },
//         { "data": "delete" }
//     ],
//     language: {
//         "sProcessing": "Procesando...",
//         "sLengthMenu": "Mostrar _MENU_ Registros",
//         "sZeroRecords": "No se encontraron resultados",
//         "sEmptyTable": "Ningún dato disponible en esta tabla",
//         "sInfo": "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
//         "sInfoEmpty": "Mostrando registros del 0 al 0 de un total de 0 registros",
//         "sInfoFiltered": "(filtrado de un total de _MAX_ registros)",
//         "sInfoPostFix": "",
//         "sSearch": "Buscar:",
//         "sUrl": "",
//         "sInfoThousands": ",",
//         "sLoadingRecords": "Cargando...",
//         "oPaginate": {
//             "sFirst": "Primero",
//             "sLast": "Último",
//             "sNext": "Siguiente",
//             "sPrevious": "Anterior"
//         },
//         "oAria": {
//             "sSortAscending": ": Activar para ordenar la columna de manera ascendente",
//             "sSortDescending": ": Activar para ordenar la columna de manera descendente"
//         },
//         "buttons": {
//             "copy": "Copiar",
//             "colvis": "Visibilidad"
//         }
//     }
// });
// }



function ConfigTableSFil() {
  var table = $("#example").DataTable({});

  $("#example").dataTable().fnDestroy();

  $("#example").dataTable({
    language: {
      sProcessing: "Procesando...",
      sLengthMenu: "Mostrar _MENU_ Registros",
      sZeroRecords: "No se encontraron resultados",
      sEmptyTable: "Ningún pedido disponible en esta Consulta",
      sInfo:
        "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
      sInfoEmpty: "Mostrando registros del 0 al 0 de un total de 0 registros",
      sInfoFiltered: "(filtrado de un total de _MAX_ registros)",
      sInfoPostFix: "",
      sSearch: "Buscar:",
      sUrl: "",
      sInfoThousands: ",",
      sLoadingRecords: "Cargando...",
      oPaginate: {
        sFirst: "Primero",
        sLast: "Último",
        sNext: "Siguiente",
        sPrevious: "Anterior",
      },
      oAria: {
        sSortAscending:
          ": Activar para ordenar la columna de manera ascendente",
        sSortDescending:
          ": Activar para ordenar la columna de manera descendente",
      },
      buttons: {
        copy: "Copiar",
        colvis: "Visibilidad",
      },
    },
  });
}



function LLenarPedido(data) {
  $(".odd").remove();
  $("#divTabla").empty();
  $("#divTabla").append(data);
  $("#buttonLoad").removeAttr("disabled");

  ConfigTable();
  $("#coverScreen").hide();
}

function EnvioPost(pedi) {
  var pedi = pedi.id;

  document.write(
    "<form action='Visualizar_Pedido'  name='form' method='POST'>" +
      "<input hidden='' type='text' name='CodPedi' value='" +
      pedi +
      "'></form> "
  );
  document.forms["form"].submit();
}

function EnviCopia(pedi) {
  var pedi = pedi.id;

  document.write(
    "<form action='Crear_pedido'  name='form' method='POST'>" +
      "<input hidden='' type='text' name='CodPedi' value='" +
      pedi +
      "'></form> "
  );
  document.forms["form"].submit();
}

function Inactividad() {
  $.ajax({
    type: "POST",
    url: "../../controller/Create/Inactividad.php",
  })
    .done(function () {})
    .fail(function () {});
}

function PedCarr() {
  try {

    cantcar=$.trim($("#cantcar").text())

    if (cantcar <1){

      if($("#Refresh").length>0){
        // console.log("estas en la vista corercta")
      }else{
        location.href="VerProductos"
      }

      // Swal.fire({
      //   title: "¡Carrito Vacio!",
      //   text: "Deseas ingresar productos?",
      //   icon: "warning",
      //   showCancelButton: true,
      //   confirmButtonColor: "#0d6efd",
      //   cancelButtonColor: "#28a745",
      //   confirmButtonText: "Continuar",
      //   cancelButtonText: "Agregar Carrito",
      // }).then((result) => {
      //   if (result.isConfirmed) {
      //     // location.href = "Crear_pedido";
      //   } else {
      //     location.href = "VerProductos";
      //   }
      // });

       

    }else{
      $.ajax({
        type: "POST",
        url: "../../controller/read/LoadCliePed.php",
      }).done(function (data) {
        InfoClien = data.split("??");
        document.write(
          "<form action='Crear_pedido'  name='form' method='POST'>" +
            "<input hidden='' type='text' name='CodCarr' value='" +
            InfoClien[0] +
            "'></form> "
        );
    
        document.forms["form"].submit();
      });
    }



    


} catch (error) {
    console.log(error);
}
}
// console.time("t1");
// console.timeEnd("t1");

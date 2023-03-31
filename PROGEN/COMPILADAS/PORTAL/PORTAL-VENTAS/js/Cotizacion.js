function FunCoti(Indice, Tipo, fecha, obs, dir) {
  try {
    //  console.log(id.id);
    if (fecha == 999) {
      Indice = Indice.id;
      date = $("#date" + Indice.id).text();
      obs = $("#obs" + Indice.id).text();
      dir = "01/01/1970";
    } else {
      date = fecha;
      obs = obs;
      dir = dir;
    }

    $.ajax({
      type: "POST",
      url: "../../controller/read/LoadCotiInd.php",
      data: { id: Indice, tipo: Tipo, date: date, obs: obs, Dir: dir },
    }).done(function (data) {
      // console.log(data);
      data = data.split("??");

      if (data[0] == 3) {
        // location.reload();
        $("#Reg"+data[5]).remove();
      
         ConfigTableCoti();
      }

      if (data[1] == 9999) {
        Swal.fire({
          title: "Cotización no encontrada!",
          text: "La cotización seleccionada ya no se encuentra disponible para su selección.",
          icon: "info",
          timer: 3000,
        }).then((result) => {
          location.reload();
        });
      } else {
        if (data[0] == 1) {
          document.write(
            "<form action='Crear_pedido'  name='form' method='POST'> </form> "
          );

          document.forms["form"].submit();
        }
      }

      if (data[0] == 2) {
        Obs = data[2];
        Dir = data[3];
        dat = data[4];

        try {
          Swal.fire({
            title: "Cotización",
            text: "Generando PDF...",
            icon: "success",
            timer: 5000,
          }).then((result) => {
            $("#coverScreen").hide();
          });
        } catch (error) {
          console.log("Error: " + error);
        }
        // console.log(Obs)
       
          location.href = "pdfPedido.php";
        
      }
    });
  } catch (error) {
    console.log(error);
  }
}



function ConfigTableCoti() {

  $("#Cotizacion").dataTable().fnDestroy();

  $('#Cotizacion').dataTable({
    "ajax": "getData.php",
    "columns": [
        { "data": "num" },
        { "data": "MessageForNote" },
        { "data": "cant" },
        { "data": "date" },
        // { "data": "dpen" },
        { "data": "Usuario" },
        { "data": "pedido" },
        { "data": "pdf" },
        { "data": "delete" }
    ],
    language: {
        "sProcessing": "Procesando...",
        "sLengthMenu": "Mostrar _MENU_ Registros",
        "sZeroRecords": "No se encontraron resultados",
        "sEmptyTable": "Ningún dato disponible en esta tabla",
        "sInfo": "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
        "sInfoEmpty": "Mostrando registros del 0 al 0 de un total de 0 registros",
        "sInfoFiltered": "(filtrado de un total de _MAX_ registros)",
        "sInfoPostFix": "",
        "sSearch": "Buscar:",
        "sUrl": "",
        "sInfoThousands": ",",
        "sLoadingRecords": "Cargando...",
        "oPaginate": {
            "sFirst": "Primero",
            "sLast": "Último",
            "sNext": "Siguiente",
            "sPrevious": "Anterior"
        },
        "oAria": {
            "sSortAscending": ": Activar para ordenar la columna de manera ascendente",
            "sSortDescending": ": Activar para ordenar la columna de manera descendente"
        },
        "buttons": {
            "copy": "Copiar",
            "colvis": "Visibilidad"
        }
    }
});
}

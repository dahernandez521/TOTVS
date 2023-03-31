$("form#filesPlain").submit(function (e) {

  e.preventDefault();
  $("#file").prop("required", true);
  if ($("#file").val() != "") {
    $("#coverScreen").show();

    var formData = new FormData(document.getElementById("filesPlain"));
    formData.append("import_data", "file");

    //  console.time("t3");
    $.ajax({
      type: "POST",
      url: "archivoplano.php",
      data: formData,
      contentType: false,
      processData: false,
      cache: false,
    })
      .done(function (data) {
        // console.timeEnd("t3");
        // console.log(data);
        console.log("================================Loading...");
        // console.log(data);
        $("#file").val("");

        data = data.split("??");
        produ = data[0];
        fallidos = data[1];
        todo= data[2];
        cont= data[3];
        // console.log(data[4]);
        // console.log(data[5]);
        $seg=0;
        if(produ==""){
          Swal.fire({
            title: "Sin Coincidencias",
            text: "Lo sentimos, no encontramos productos relacionados.",
            icon: "info",
          }).then((result) => {
            $("#coverScreen").hide();
          });
        }
        if (produ != "") {
          $("#tbody").empty();
          $("#tbody").append(produ);
          $(".Val-Pre").css("display", "none"); // oculta los campos de datos originales
          
          ValDesc();

          $("#ModalPedido").empty();
          $("#ModalPedido").append(data[6])
          // LoadModalPed()
         
          $seg=1
         
        }

        if (fallidos == "1") {
          window.open('error.php');
          $seg=1
        } 

    
   
        
        // const table = document.getElementById("tablaprueba");
        // const rowCount = table.rows.length;

        // for (var vd = 1; vd <= rowCount - 1; vd++) {
        //   $("#td" + vd + "").append(
        //     '<datalist id="produc-list' +
        //       vd +
        //       '" class="lista_prod">  </datalist>'
        //   );
        //   // ModalPedido(vd);

        // }
       

        const tablea = document.getElementById("tablaprueba");
        const rowCounta = tablea.rows.length;
        Linea = 0;
  
        for (var sd = 1; sd <= rowCounta + 1000; sd++) {
          // // console.log("sd:  ", sd);
  
          if (Linea == rowCounta) {
            break;
          }
          $("#td" + sd + "").append(
            '<datalist id="produc-list' +
            sd +
              '" class="lista_prod">  </datalist>'
          );
          total(sd);
          Linea++;
  
        }

        ajax_pro();


        if($seg==1){
          // console.log("Changed...");
          $("#coverScreen").hide();
        }else{
          // console.log("Loading...");
        }



      })
      .fail(function () {
        // alert("Hubo un errror al cargar el archivo plano");
      });
  }
});

function LoadModalPed(){
  // console.log("dentro del modal");
  $.ajax({
    type: "POST",
    url: "../../controller/read/ModalProd.php",
  })
    .done(function (data) {
        // console.log(data);
      

      $("#ModalPedido").empty();
      $("#ModalPedido").append(data)

      const tablea = document.getElementById("tablaprueba");
      const rowCounta = tablea.rows.length;
      Linea = 0;

      for (var sd = 1; sd <= rowCounta + 1000; sd++) {
        // // console.log("sd:  ", sd);

        if (Linea == rowCounta) {
          break;
        }
        total(sd);
        Linea++;

      }

    })
    .fail(function () {
      // alert("Hubo un errror al cargar los precios");
    });
}

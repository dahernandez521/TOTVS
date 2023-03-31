$(window).on('load', function () {

$("#coverScreen").show();

$.ajax({
  type: "POST",
  url: "../../controller/read/ConsCabDetPedi.php",
})
  .done(function (Cabeza) {

      $("#CabezaDetPedi").append(Cabeza);

  
    
  })
  .fail(function () {
    alert("Hubo un errror al cargar el pedido");
  });


$.ajax({
  type: "POST",
  url: "../../controller/read/ConsDetPedi.php",
})
  .done(function (Returns) {

    Cuerpo = Returns.split("??");
    fecha = Cuerpo[0];
    data = Cuerpo[1];



    if(data==999){
      $("#coverScreen").hide();
      mantenimeinto("Consultar_Pedidos")  //en caso de error en consulta se informa de manteniemiento y se manda la url
    }else{

      $("#date").val(fecha);
      $("#DetPedi").append(data);
      ConfigTableSFil();
      $("#coverScreen").hide();
    }
  
    
  })
  .fail(function () {
    alert("Hubo un errror al cargar los pedidos");
  });


  
  
  });




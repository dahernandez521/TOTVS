
ConfigTableSFil()
$("#coverScreen").hide();

$("#buttonLoad").click(function () {
  Inactividad()
  $("#coverScreen").show();

 
  FecInic = $("#FecInic").val();
  FecFini = $("#FecFini").val();

  var datos = "FecInic=" + FecInic + "&FecFini=" + FecFini;

  $.ajax({
    type: "POST",
    url: "../../controller/read/Cartera.php",
    data: datos,
  })
    .done(function (data) {
   
      $("#DivCartera").empty();
      $("#DivCartera").append(data);
      ConfigTableSFil()


      $("#coverScreen").hide();
    })
    .fail(function () {
      // alert("Hubo un errror al cargar la Cartera");
    });

});




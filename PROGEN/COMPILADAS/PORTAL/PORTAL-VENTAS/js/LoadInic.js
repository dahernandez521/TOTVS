$.ajax({
    type: "POST",
    url: "../../controller/read/LoadInic.php",
    data: datos,
  })
    .done(function (data) {

    })
    .fail(function () {
      // alert("Hubo un errror al cargar los productos");
    });
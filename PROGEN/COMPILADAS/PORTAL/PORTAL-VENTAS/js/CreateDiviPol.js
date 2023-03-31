function Load_DiviPola() {
  if (window.localStorage) {
    if (
      window.localStorage.getItem("Departaments") !== undefined &&
      window.localStorage.getItem("Departaments")
    ) {
      var array = localStorage.getItem("Departaments");

      $.ajax({
        type: "POST",
        url: "../../controller/read/ConsLocalDepart.php",
        data: { Depart: array },
      })
        .done(function (data) {
          // console.log("Departamentos:   "+data);
          $("#Departamento").empty();
          $("#Departamento").append(data);
        })
        .fail(function () {
          // alert("Hubo un errror al cargar los productos");
        });
    } else {
      CreateDepartaments();
    }
  }

  if (window.localStorage) {
    if (
      window.localStorage.getItem("Municips") !== undefined &&
      window.localStorage.getItem("Municips")
    ) {
      var array = localStorage.getItem("Municips");

      $.ajax({
        type: "POST",
        url: "../../controller/read/ConsLocalMunici.php",
        data: { Munici: array },
      })
        .done(function (data) {
          $("#Municipio").empty();
          $("#Municipio").append(data);
        })
        .fail(function () {
          // alert("Hubo un errror al cargar los productos");
        });
    } else {
      CreateMunicips();
    }
  }


  $("#Departamento").change(function () {
    $.ajax({
      type: "POST",
      url: "../../controller/read/ConsMuniSel.php",
      data: { Departamento: $("#Departamento").val() },
    })
      .done(function (data) {
        $("#Municipio").empty();
        $("#Municipio").append(data);
      })
      .fail(function () {
        // alert("Hubo un errror al cargar los productos");
      });
  });
  
}

Load_DiviPola();

function CreateDepartaments() {
  $.ajax({
    type: "POST",
    url: "../../controller/api/ws_verify_Depart.php",
  })
    .done(function (data) {
      localStorage.setItem("Departaments", data);
    })
    .fail(function () {
      // alert("Hubo un errror al cargar los Departamentos");
    });
}

function CreateMunicips() {
  $.ajax({
    type: "POST",
    url: "../../controller/api/ws_verify_Munici.php",
  })
    .done(function (data) {
      localStorage.setItem("Municips", data);
    })
    .fail(function () {
      // alert("Hubo un errror al cargar los Municipios");
    });
}


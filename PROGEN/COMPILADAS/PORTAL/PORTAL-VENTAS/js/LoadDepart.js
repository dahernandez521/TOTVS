if (window.localStorage) {
  if (
    window.localStorage.getItem("Departaments") !== undefined &&
    window.localStorage.getItem("Departaments")
  ) {
    $("#coverScreen").show();
    var array = localStorage.getItem("Departaments");

    $.ajax({
      type: "POST",
      url: "../../controller/read/ConsLocalDepart.php",
      data: { array: array },
    })
      .done(function (data) {
        $("#Departamento").empty();
        $("#Departamento").append(data);
      })
      .fail(function () {
        alert("Hubo un errror al cargar los Departamentos");
      });
  } else {
    $("#coverScreen").hide();
  }
}
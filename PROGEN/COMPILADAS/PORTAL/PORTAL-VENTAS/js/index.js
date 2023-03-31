localStorage.removeItem("Maestro_productos");
localStorage.removeItem("Modalidades");
 localStorage.removeItem("RefCruz_productos");
localStorage.removeItem("ReNego");
localStorage.removeItem("FoPago");
localStorage.removeItem("ImpIVA");
localStorage.removeItem("Lis_Prod");
localStorage.removeItem("Clien");


$("#Filiales").hide();

function mostrarPassword() {
  var cambio = document.getElementById("floatingPassword");
  if (cambio.type == "password") {
    cambio.type = "text";
    $("#ShowOne").removeClass("fa fa-eye-slash").addClass("fa fa-eye");
  } else {
    cambio.type = "password";
    $("#ShowOne").removeClass("fa fa-eye").addClass("fa fa-eye-slash");
  }
}

$(document).ready(function () {
  //CheckBox mostrar contraseña

  $("#show_password_One").click(function () {
    var cambio = document.getElementById("NewPass");
    if (cambio.type == "password") {
      cambio.type = "text";
      $("#NewShowOne").removeClass("fa fa-eye-slash").addClass("fa fa-eye");
    } else {
      cambio.type = "password";
      $("#NewShowOne").removeClass("fa fa-eye").addClass("fa fa-eye-slash");
    }
  });

  $("#show_password_Two").click(function () {
    var cambio = document.getElementById("ConPass");
    if (cambio.type == "password") {
      cambio.type = "text";
      $("#ConShowOne").removeClass("fa fa-eye-slash").addClass("fa fa-eye");
    } else {
      cambio.type = "password";
      $("#ConShowOne").removeClass("fa fa-eye").addClass("fa fa-eye-slash");
    }
  });

  $("#ConPass").keyup(function () {
    if ($.trim($("#NewPass").val()) != "") {
      if ($.trim($("#ConPass").val()) == $.trim($("#NewPass").val())) {
        $("#ConPass").css("background-color", "rgb(9 255 28 / 50%)");
        $("#NewPass").css("background-color", "rgb(9 255 28 / 50%)");
        $('#Change').removeAttr("disabled");
        $('#succes').text('');
      } else {
        $("#ConPass").css("background-color", "rgba(255, 0, 0, .5)");
        $("#NewPass").css("background-color", "rgba(255, 0, 0, .5)");
        $('#Change').attr('disabled', 'disabled');
        $('#succes').text('Las contraseñas no coinciden');
      }

    }
  });


  $("#NewPass").keyup(function () {
    if ($.trim($("#ConPass").val()) != "") {
      if ($.trim($("#ConPass").val()) == $.trim($("#NewPass").val())) {
        $("#ConPass").css("background-color", "rgb(9 255 28 / 50%)");
        $("#NewPass").css("background-color", "rgb(9 255 28 / 50%)");
        $('#Change').removeAttr("disabled");
        $('#succes').text('');
      } else {
        $("#ConPass").css("background-color", "rgba(255, 0, 0, .5)");
        $("#NewPass").css("background-color", "rgba(255, 0, 0, .5)");
        $('#Change').attr('disabled', 'disabled');
        $('#succes').text('Las contraseñas no coinciden');
        
      }
    }
  });
});


$("#Change").click(function () {

  Swal.fire(
    {
      title: "Espere Por Favor",
      text: "Estamos validando la información ingresada",
      icon: "info",
    },
    function () {}
  );

  $.ajax({
    type: "POST",
    url: "controller/read/LoadMailRes.php",
    data: { Mail: $("#ValMail").val() },
  }).done(function (data) {

    resp=data.split("??");
    // console.log(resp[0]);
    // console.log(resp[1]);
    // console.log(resp[2]);
    if (resp[1]==1){
      Swal.fire(
        {
          title: "Correcto",
          text: "Tu nueva contraseña ha sido enviada al correo ingresado",
          icon: "success",
           timer: 5000,
        },
        function () {}
      );
    }else{
      Swal.fire(
        {
          title: "Advertencia",
          text: "No encontramos coincidencias con el correo ingresado",
          icon: "info",
           timer: 5000,
        },
        function () {}
      );
    }
   
  });
});

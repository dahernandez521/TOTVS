

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
    url: "../../controller/api/ws_verify_UpdPass.php",
    data: { Pass: $("#ConPass").val() },
  }).done(function (resp) {
    console.log(resp)
    if (resp==1){
      Swal.fire(
        {
          title: "Success",
          text: "Tu Contraseña ha sido modificada con exito",
          icon: "success",
        },
        function () {}
      );
    }else{
      Swal.fire(
        {
          title: "Information",
          text: "No pudimos realizar el cambio de tu contraseña",
          icon: "info",
        },
        function () {}
      );
    }
   
  });
});

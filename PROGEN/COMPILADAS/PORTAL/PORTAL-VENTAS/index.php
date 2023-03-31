<?php
error_reporting(0);
//session_start();
//session_unset();
//session_destroy();
//session_write_close();
//setcookie(session_name(),'',0,'/');
//session_regenerate_id(true);
include "model/WebService/rest_services.php";
require_once("controller/verification/filiales.php");
require_once("controller/verification/errors.php");
require_once("controller/verification/functions.php");
require_once("controller/verification/validation_session.php");


?>

<!doctype html>
<html lang="es">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <link rel="shortcut icon" href="img/favicon.ico" />
  <link rel="stylesheet" href="bootstrap-5.0.2-dist/css/bootstrap.css">
  <link rel="stylesheet" href="css/signin.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

  <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
  <script src="Alert/dist/sweetalert2.all.min.js"></script>
    <script src="Alert/dist/sweetalert2.min.js"></script>
    <link rel="stylesheet" href="Alert/dist/sweetalert2.min.css">

    <!-- <script src="https://code.jquery.com/jquery-3.3.1.js"></script> -->
    <script src="js/jquery-3.6.1.min.js"></script>
  <title>Totvs Portal de Ventas</title>
</head>

<body>
  <main class="m-0 vh-100 row justify-content-center align-items-center">
    <form method="POST" autocomplete="off">
      <div class="container card col-auto p-4" id="div1">
        <div class="p-3" id="div2">
          <img
            src="https://static.wixstatic.com/media/c538a9_ec43143e34184572a60944bccf1fbcff~mv2.png/v1/fill/w_351,h_100,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/PROGEN.png"
            alt="logo_progen" width="80%" class="card-img-top">
        </div>
        <div class="p-3" id="div3">
          <h3 class="pb-3">Portal de Ventas</h3>
        </div>
        <div class="mb-3" id="div4">
          <input type="text" class="form-control" id="floatingInput" placeholder="Usuario" name="userportal"
            maxlength="56">
        </div>

        <div class="row">
          <div class="col-md-12">
            <div class="input-group">
              <input type="password" autocomplete="on" class="form-control" id="floatingPassword" placeholder="Contraseña" name="clave"
               maxlength="8">
              <div class="input-group-append">
                <button id="show_password" class="btn btn-primary" type="button" onclick="mostrarPassword()"> <span
                    class="fa fa-eye-slash icon" id="ShowOne"></span> </button>
              </div>
            </div>
          </div>
        </div>




        <div class="mb-3">
          <select class="form-select form-select-sm" id="Filiales" aria-label=".form-select-sm" name='empresa'>
            <?php
            filiales(); //se crea la funcion para organizar el codigo y poder llamarlo
            
            ?>
          </select>
        </div>
        <?php
        view_error();
        ?>

        <div class="mt-2 justify-content-center align-items-center" id="div7">
          <button class="w-100 btn btn-lg btn-primary" type="submit" id="button">Ingresar</button>
        </div>

        <div class="mb-2" id="div6">
          <label>
             <a aria-current="page" class="nav-link" href="#" data-bs-toggle="modal" data-bs-target="#Mail">Olvidó
              contraseña?</a> 
            <!-- <button type="button" class="btn" data-bs-toggle="modal" data-bs-target="#exampleModal' . $cont . '">
                                <img src="../../img/lupa.png" alt="ver" width="20px">
                                </button> -->
          </label>
        </div>

        <div class="mt-2" id="div7">
          <p class="text-muted">&copy; 2017 - 2023</p>
          <img
            src="data:image/png;base64,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"
            alt="logo_totvs" width="100px">
        </div>
      </div>
    </form>



    <div class="modal fade" id="Mail" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
      <div class="modal-dialog ">
        <div class="modal-content">
          <div class="modal-header">
            <h1 class="modal-title fs-5" id="exampleModalLabel">Cambio de Contraseña</h1>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
          </div>
          <div class="modal-body">
            <div class="row">
              <form action="#">

                <div class="row">
                  <div class="col-md-12">
                    <div class="input-group">
                      <label for="">Se enviara la nueva contraseña al correo registrado a continuación</label>
                      <input type="email" class="form-control" id="ValMail" placeholder="Correo de Recuperación"
                        name="mail"  maxlength="50">
                      <div class="input-group-append">
                      </div>
                    </div>
                  </div>
                </div>
                <br>


              </form>
            </div>
          </div>
          <div class="modal-footer">
           
            <!-- <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button> -->
            <button type="button" class="btn btn-primary" id="Change"  data-bs-dismiss="modal">Enviar</button>
          </div>
        </div>
      </div>
    </div>



  </main>
</body>


<script src="assets/dist/js/bootstrap.min.js"></script>
<script src="js/jquery-3.6.1.min.js" .></script>
<script src="js/index.js"></script>

</html>
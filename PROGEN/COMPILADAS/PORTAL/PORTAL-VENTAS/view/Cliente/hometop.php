<?php
require_once("../../controller/verification/functions.php");
$_SESSION['logged_time'] = time();
?>


<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="UTF-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="../../bootstrap-5.0.2-dist/css/bootstrap.css">
  <link rel="stylesheet" href="../../css/navbar.css">
  <link rel="shortcut icon" href="../../img/favicon.ico" />
  <link rel="stylesheet" href="../../css/cliente.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/4.7.0/css/font-awesome.min.css">

  <title>Portal de Ventas - Cliente</title>

</head>

<body>
  <div>
    <nav class="navbar navbar-expand-lg bg-light" id="menu">
      <div class="container-fluid">
        <a href="#" class="pt-2 pb-2" id="itemMenu">
          <img src="../../img/PROGEN_logo.webp" alt="Logo Progen" width="100%" height="50">
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent"
          aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
          <img class="navbar-toggler-icon" src="../../img/menu.png" alt="Logo Progen" width="100%" height="10">
        </button>

        <div class="collapse navbar-collapse" id="navbarSupportedContent">

          <ul class="navbar-nav me-auto mb-2 mb-lg-0">

            <?php

            if (isset($_SESSION['Cliente'])) {

              ?>
              <!-- <li class="nav-item" id="itemMenu">
                                                      <a class="nav-link" aria-current="page" href="inicio_cliente.php">Inicio</a>
                                                  </li> -->
              <li class="nav-item" id="itemMenu">
                <a class="nav-link" aria-current="page" href="Consultar_Clientes">Clientes</a>
              </li>


              <li class="nav-item" id="itemMenu">
                <a class="nav-link" aria-current="page" href="VerProductos">Productos</a>
              </li>

              <li class="nav-item" id="itemMenu">
                <a class="nav-link" aria-current="page" href="Cotizaciones">Cotizaciones</a>
              </li>

              <li class="nav-item dropdown" id="itemMenu">
                <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown"
                  aria-expanded="false">
                  Pedidos
                </a>
                <ul class="dropdown-menu">

                  <li><a class="dropdown-item" href="Crear_pedido">Crear Pedido</a></li>
                  <li><a class="dropdown-item" href="Consultar_pedidos">Consultar Pedidos -
                      Cliente</a></li>
                  <!-- <li><a class="dropdown-item" href="Consultar_Allpedidos.php">Consultar Pedidos - General</a></li> -->

                  <!-- <li><a class="dropdown-item" href="Inicio_Seguimiento.php">Seguimiento Pedidos</a></li> -->
                </ul>
              </li>
              <li class="nav-item" id="itemMenu">
                <a class="nav-link" aria-current="page" href="Cartera">Cartera</a>
              </li>
              <?php
            }
            ?>


          </ul>


          <form>



            <li class="nav-item dropdown d-flex">



              <?php
              if (isset($_SESSION["login"])) {
                $login = $_SESSION["login"];
                if (isset($login["NOME"])) {


                  ?>


                  <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown"
                    aria-expanded="false">
                    <?php echo $login["NOME"];

                    if (isset($_SESSION['Cliente'])) {

                      foreach ($_SESSION['clientes'] as $key => $Detalle) {
                        if ($Detalle['code'] === $_SESSION['Cliente']) {

                          if ($Detalle['store'] === $_SESSION['Loja']) {


                            ?>


                            <?php
                            echo "<br>" . $Detalle['code'] . " - " . $Detalle['namefan'] . " - " . $Detalle['store'];

                            break;

                          }
                        }
                      }
                    }
                    ?>
                  </a>
                  <ul class="dropdown-menu">
                    <li><a aria-current="page" class="nav-link" href="#" data-bs-toggle="modal"
                        data-bs-target="#Pass">Cambiar Contraseña</a></li>
                  </ul>

                  <?php


                } else {
                  echo "Sin Servicio";
                }
              } else {
                echo "Sin Servicio";
              }



              ?>



              <a class="nav-link" href="../../controller/verification/logout.php"><img src="../../img/cerrar-sesion.png"
                  alt="" width="30px"></a>
              <?php

              ?>
            </li>
          </form>
        </div>

      </div>
    </nav>
    <?php

    if (isset($_SESSION['Cliente'])) {
      ?>

      <div class="container" style="text-align: end;">
        <div style="text-align: end;" id="MiCar">

        </div>
      </div>
      <?php

    }





    ?>

    <?php

    if (isset($_SESSION['Clienteqw'])) {

      foreach ($_SESSION['clientes'] as $key => $Detalle) {
        if ($Detalle['code'] === $_SESSION['Cliente']) {

          if ($Detalle['store'] === $_SESSION['Loja']) {

            ?>
            <div class="col-4 mb-4" id="divTitulo1">
              <h4 id="Titulo" style="font-size: 15px; font-weight: bold;">Cliente actualmente en uso</h4>
              <h4 id="Titulo" style="font-size: 15px;">Nit:
                <?php echo $Detalle['code'] ?>
              </h4>
              <h4 id="Titulo" style="font-size: 15px;">Nombre:
                <?php echo $Detalle['namefan'] ?>
              </h4>
              <h4 id="Titulo" style="font-size: 15px;">Tienda:
                <?php echo $Detalle['store'] ?>
              </h4>
            </div>
            <?php
            break;

          }
        }
      }
    }

    ?>

    <div class="modal fade" id="Pass" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
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
                      <input type="password" class="form-control" id="NewPass" placeholder="Nueva Contraseña"
                        name="clave" autocomplete="current-password" maxlength="8">
                      <div class="input-group-append">
                        <button id="show_password_One" class="btn btn-primary" type="button">
                          <span class="fa fa-eye-slash icon" id="NewShowOne"></span> </button>
                      </div>
                    </div>
                  </div>
                </div>
                <br>


                <div class="row">
                  <div class="col-md-12">
                    <div class="input-group">
                      <input type="password" class="form-control" id="ConPass" placeholder="Confirmar Contraseña"
                        name="clave" autocomplete="current-password" maxlength="8">
                      <div class="input-group-append">
                        <button id="show_password_Two" class="btn btn-primary" type="button">
                          <span class="fa fa-eye-slash icon" id="ConShowOne"></span> </button>
                      </div>
                    </div>
                  </div>
                </div>


              </form>
            </div>
          </div>
          <div class="modal-footer">

            <label disabled id="succes"></label>
            <!-- <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button> -->
            <button type="button" class="btn btn-primary" id="Change" disabled data-bs-dismiss="modal">Cambiar</button>
          </div>
        </div>
      </div>
    </div>

  </div>


  <!-- <script src="../../js/ViewCarr.js"></script> -->
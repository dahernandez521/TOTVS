<?php
error_reporting(0);
require_once("../../controller/verification/functions.php");

session_start();

valida_sesion();

valida_clien();

// include '../../controller/api/ws_verify_Cartera.php';
// http://190.60.28.46:8095/rest/UANDCART/VerCartera?COD=860511458&DIni=20221212&DFin=20221220



include 'homeTop.php';

?>

<head>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.19/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" type="text/css" href="../../css/Crear_Pedido.css">
    <link rel="stylesheet" href="../../css./fuente_raleway.css">
    <script src="https://code.jquery.com/jquery-3.3.1.js"></script>
    <script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.19/js/dataTables.bootstrap4.min.js"></script>
    <script src="../../Alert/dist/sweetalert2.all.min.js"></script>
    <script src="../../Alert/dist/sweetalert2.min.js"></script>
    <link rel="stylesheet" href="../../Alert/dist/sweetalert2.min.css">
    <script src="../../js/sweet_alert.js"></script>
</head>
<div id="coverScreen" class="LockOn"> </div>
<div class="container-fluid p-5 row" id="tabla">


    <div class="col-12 mb-4" id="divTitulo1">
        <h4 id="Titulo" style="padding-top: 6px; font-size: 27px;"><a href="./Consultar_Clientes">Clientes</a> /
            Documentos Pendientes</h4>
    </div>

    <div class="col-12 mb-3 pt-2" id="divTitulo2">
        <h5>Información Básica</h5>
    </div>
    <?php

    if (isset($_SESSION['Cliente'])) {
        // echo $_SESSION['Cliente']; 
        date_default_timezone_set("America/Bogota");

        foreach ($_SESSION['clientes'] as $key => $Detalle) {
            if ($Detalle['code'] === $_SESSION['Cliente']) {

                if ($Detalle['store'] === $_SESSION['Loja']) {


                    echo '
                <div class="row" id="CabezaPedi">
                    <div class="col-md-3">
                        <label for="inputIdCliente" class="form-label">Id Cliente</label>
                        <input type="text" class="form-control" id="inputIdCliente" placeholder="' . $Detalle['code'] . '" disabled value="' . $Detalle['code'] . '">

                    </div>

                    <div class="col-md-8">
                        <label for="inputSucursal" class="form-label">Nombre</label>
                        <input type="text" class="form-control" id="inputSucursal" placeholder="' . $Detalle['namefan'] . '" disabled>
                    </div>


                    <div class="col-md-8">
                        <label for="inputSucursal" class="form-label">Email</label>
                        <input type="text" class="form-control" id="inputSucursal" placeholder="' . $Detalle['email'] . '" disabled>
                    </div>


                    <div class="col-md-1">
                        <label for="inputSucursal" class="form-label">Tienda</label>
                        <input type="number" class="form-control" id="inputSucursal" placeholder="' . $Detalle['store'] . '" disabled>
                    </div>

                </div>
            ';
                    break;
                }
            }
        }
    }
    ?>



    <div class="col-12 mt-4 pt-2" id="divTitulo2">
        <h5>Detalle </h5>
    </div>

    <div class="form-row align-items-center">

        <div class="col-auto">
            <div class="input-group mb-2">
                <button type="button" id="buttonLoad" class="btn btn-success">Consultar</button>
            </div>
        </div>
        <div class="col-auto">
            <div class="input-group mb-2">
                <div class="input-group-prepend">
                    <div class="input-group-text">Fecha Incial</div>
                </div>
                <input type="date" value=<?php echo date("Y-m-d") ?> class="form-control" id="FecInic"
                    placeholder="Username">
            </div>
        </div>
        <div class="col-auto">
            <div class="input-group mb-2">
                <div class="input-group-prepend">
                    <div class="input-group-text">Fecha Final</div>
                </div>
                <input type="date" value=<?php echo date("Y-m-d") ?> class="form-control" id="FecFini"
                    placeholder="Username">
            </div>
        </div>
        <br>
        <br>
        <br>

    </div>


    <div id="DivCartera" class="mt-3">
        <table id="example" class="table table-striped table-bordered mt-3">
            <thead style="background-color: #0D729C;color: white;">
                <tr>
                    <th scope="col">Tipo de Documento</th>
                    <th scope="col">Número</th>
                    <th scope="col">Fec Emisión</th>
                    <th scope="col">Fec Venc </th>
                    <!-- <th scope="col">Fec Venc Real</th> -->
                    <th scope="col">Ult Trans</th>
                    <th scope="col">Valor Total</th>
                    <th scope="col">Saldo</th>
                    <th scope="col"></th>
                </tr>
            </thead>
            <tbody id="cuerpoTabla">
                <?php
                if (isset($_SESSION['DeCart'])) {

                    echo $_SESSION['DeCart'];

                }
                ?>

            </tbody>
        </table>



        <?php
        if (isset($_SESSION['Total'])) {

            echo $_SESSION['Total'];

        } else {
            ?>

            <div>
                <table class="table table-bordered mt-3">
                    <thead>
                        <tr>
                            <th width="80%" scope="col" style="text-align: end;">Valor Total</th>
                            <th><input class="form-control" type="text"
                                    style="background-color: white;text-align: end;border: none;font-weight: 700;"
                                    placeholder="$ " disabled id="ValTota"></th>
                        </tr>
                    </thead>
                </table>
            </div>


            <?php

        }
        ?>

        <?php
        if (isset($_SESSION['Modal'])) {

            echo $_SESSION['Modal'];

        }

        ?>


    </div>




</div>



<?php
include 'homebott.php'
    ?>
<script src="../../js/Cartera.js"></script>
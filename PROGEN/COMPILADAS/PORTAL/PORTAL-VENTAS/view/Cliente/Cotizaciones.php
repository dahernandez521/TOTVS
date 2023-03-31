<?php
error_reporting(0);
require_once("../../controller/verification/functions.php");

session_start();


valida_sesion();

valida_clien();

date_default_timezone_set("America/Bogota");



include 'hometop.php';
?>

<head>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.19/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="../../css./fuente_raleway.css">
    <script src="../../Alert/dist/sweetalert2.all.min.js"></script>
    <script src="../../Alert/dist/sweetalert2.min.js"></script>
    <link rel="stylesheet" href="../../Alert/dist/sweetalert2.min.css">

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.css">

    <link rel="stylesheet" href="../../css/dataTables.css">
    <!-- <script src="https://code.jquery.com/jquery-3.3.1.js"></script> -->
    <script src="../../js/jquery-3.6.1.min.js"></script>
    <script src="../../js/dataTables.js"></script>
    <script src="../../js/dataTables_bootstrap.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/Consultar_Pedidos.css">


</head>

<div class="container-fluid p-5 row" id="tabla">
    <div class="col-12" id="divTitulo">
        <h4 style="font-size: 27px;">Cotizaciones</h4>
    </div>
    <div id="coverScreen" class="LockOn">
        <!-- <div class="loader-text"></div> -->
    </div>


    <div id="divTabla" class="mt-3">
        <table id="Cotizacion" class="table table-striped table-bordered mt-3">
            <thead style="background-color: #0D729C;color: white;">
                <tr>

                    <th scope="col">Num Cotización</th>
                    <th scope="col">Observación</th>
                    <th scope="col"># items</th>
                    <th scope="col">Fecha de Emision</th>
                    <!-- <th scope="col">Dias a vencer</th> -->
                    <th scope="col">Usuario</th>
                    <th scope="col">Usar</th>
                    <th scope="col">Imprimir</th>
                    <th scope="col">Eliminar</th>
                </tr>
            </thead>
            <tbody id="cuerpoTabla">

            </tbody>
        </table>
    </div>
</div>



<script src="../../js/script.js"></script>

<?php
include 'homebott.php'
    ?>
<script src="../../js/mantenimiento.js"></script>
<!-- <script src="../../js/LoadCarrito.js"></script> -->
<script src="../../js/Cotizacion.js"></script>

<script>
    $(document).ready(function () {

        ConfigTableCoti()
        $("#coverScreen").hide();
    });




</script>
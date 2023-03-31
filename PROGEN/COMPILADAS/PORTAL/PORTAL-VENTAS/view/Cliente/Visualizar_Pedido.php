<?php
  error_reporting(0);
require_once("../../controller/verification/functions.php");

session_start();

valida_sesion();

ValidaPedido();

// include '../../ws_verify_DetPedi.php';
// include '../../ws_verify_DetPediTwo.php';

// include '../../controller/api/ws_verify_DetPedi.php';
// include '../../controller/api/ws_verify_DetPediTwo.php';

include 'homeTop.php';
?>

<head>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.19/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="../../css./fuente_raleway.css">
    <script src="https://code.jquery.com/jquery-3.3.1.js"></script>
    <script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.19/js/dataTables.bootstrap4.min.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/Consultar_Pedidos.css">
    <script src="../../Alert/dist/sweetalert2.all.min.js"></script>
    <script src="../../Alert/dist/sweetalert2.min.js"></script>
    <link rel="stylesheet" href="../../Alert/dist/sweetalert2.min.css">
</head>
<div class="container-fluid p-5 row  align-self-center justify-content-center" style="">
    <form class="row" id="form">
        <div class="col-12 mb-3" id="divTitulo1">
            <h4><a href="./Consultar_Pedidos">Pedidos</a> / Visualizar Pedido</h4>
        </div>
        <div id="coverScreen" class="LockOn">
        </div>
        <div class="col-12 mb-3 pt-2" id="divTitulo2">
            <h5>Información Básica</h5>
        </div>



        <div class="row" id="CabezaDetPedi">

        </div>


        <div class="col-12 mt-4 mb-4 pt-2" id="divTitulo2">
            <h5>Detalle Pedido</h5>
        </div>
        <div class="col-12" id="DetPedi"></div>


    </form>
</div>

<?php
include 'homebott.php'
    ?>
<script src="../../js/mantenimiento.js"></script>
<script src="../../js/CreateDiviPol.js"></script>
<script src="../../js/LoadDetPed.js"></script>

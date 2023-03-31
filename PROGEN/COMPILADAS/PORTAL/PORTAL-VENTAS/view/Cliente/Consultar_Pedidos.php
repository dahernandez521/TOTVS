<?php
error_reporting(0);
require_once("../../controller/verification/functions.php");

session_start();


 valida_sesion();

 valida_clien();

date_default_timezone_set("America/Bogota");


// include '../../controller/api/ws_verify_pedi.php';


include 'hometop.php';
?>

<head>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.19/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" href="../../css./fuente_raleway.css">
    <script src="https://code.jquery.com/jquery-3.3.1.js"></script>
    <script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.19/js/dataTables.bootstrap4.min.js"></script>
    <link rel="stylesheet" type="text/css" href="../../css/Consultar_Pedidos.css">
</head>

<div class="container-fluid p-5 row" id="tabla">
    <div class="col-12" id="divTitulo">
        <h4 style="font-size: 27px;">Pedidos Generados</h4>
    </div>
    <div id="coverScreen" class="LockOn">
        <!-- <div class="loader-text"></div> -->
    </div>
    <div class="form-row align-items-center">
        
        <div class="col-auto">
            <div class="input-group mb-2">
                <button type="button" id="buttonLoad"  class="btn btn-success">Consultar</button>
            </div>
        </div>
        <div class="col-auto">
            <div class="input-group mb-2">
                <div class="input-group-prepend">
                    <div class="input-group-text">Fecha Incial</div>
                </div>
                <input type="date" value=<?php echo date("Y-m-d")?>  class="form-control" id="FecInic" placeholder="Username">
            </div>
        </div>
        <div class="col-auto">
            <div class="input-group mb-2">
                <div class="input-group-prepend">
                    <div class="input-group-text">Fecha Final</div>
                </div>
                <input type="date" value=<?php echo date("Y-m-d")?> class="form-control" id="FecFini" placeholder="Username">
            </div>
        </div>
        <br>
        <br>
        <br>

    </div>
    <div id="divTabla" class="mt-3">
        <table id="example" class="table table-striped table-bordered mt-3">
            <thead style="background-color: #0D729C;color: white;">
                <tr>
                    <th scope="col"></th>
                    <th scope="col">Número</th>
                    <th scope="col">Tienda</th>
                    <th scope="col">Dirección de Entrega</th>
                    <th scope="col">Fecha Generación</th>
                    <th scope="col">Valor Total</th>
                    <th scope="col">Acciones</th>
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
    <script src="../../js/CreateDiviPol.js"></script>
<script src="../../js/LoadPed.js"></script>
<script src="../../js/ImpIVA.js"></script>

<script>
ConfigTable()
</script>

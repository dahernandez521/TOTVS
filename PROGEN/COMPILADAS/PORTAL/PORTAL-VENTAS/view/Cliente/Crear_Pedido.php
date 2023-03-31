<?php
error_reporting(0);
require_once("../../controller/verification/functions.php");

session_start();

valida_sesion();

valida_clien();

valida_copia();

Valida_carrito();

//  print_r($_SESSION["login"]['LOGIN']);

// print_r($_SESSION["productos_obj"]);
// print_r("impuestso: ".$_SESSION["ImpIVA"]);
// include '../../controller/api/ws_verify_ReNego.php';
// include '../../controller/api/ws_verify_produ.php';
// include '../../controller/api/ws_verify_ImpIVA.php';

// print_r($_SESSION["DetRegla"]);
include 'homeTop.php';
?>

<head>
    <!-- <script src="../../js/jquery-3.6.1.min.js"></script> -->
    <link rel="stylesheet" type="text/css" href="../../css/Crear_Pedido.css">
    <link rel="stylesheet" href="../../css/fuente_raleway.css">
    <script src="../../Alert/dist/sweetalert2.all.min.js"></script>
    <script src="../../Alert/dist/sweetalert2.min.js"></script>
    <link rel="stylesheet" href="../../Alert/dist/sweetalert2.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.css">

    <link rel="stylesheet" href="../../css/dataTables.css">
    <!-- <script src="https://code.jquery.com/jquery-3.3.1.js"></script> -->
    <script src="../../js/jquery-3.6.1.min.js"></script>
    <script src="../../js/dataTables.js"></script>
    <script src="../../js/dataTables_bootstrap.js"></script>
</head>

<?php
if (isset($_POST['CodCarr'])) {
    echo '<input type="hidden" id="carrito" disabled value="' . trim($_POST['CodCarr']) . '">';
}

?>


<div class="container-fluid p-5 row">

    <div id="coverScreen" class="LockOn"> </div>
    <div id="coverScreenshop" class="LockOn"> </div>
    <div id="Imp" class="LockOn"> </div>
    <div id="tes"></div>

    <div class="col-12 mb-4" id="divTitulo1">
        <h4 id="Titulo" style="padding-top: 6px; font-size: 27px;"><a href="./Consultar_Pedidos">Pedidos</a> /
            Crear Pedido</h4>
    </div>


    <form class="row" id="form">
        <div class="col-12 mb-3 pt-2" id="divTitulo2">
            <h5>Información Básica</h5>
        </div>
        <!-- <div class="col-md-3">
            <label for="inputNumero" class="form-label">N° Pedido</label>
            <input type="number" class="form-control" id="inputNumero" placeholder="000006" disabled>
        </div> -->
        <?php
        include 'cabezaNewPedido.php';
        ?>
        <div class="col-12 mt-4 pt-2" id="divTitulo2">
            <h5>Detalle Pedido</h5>
        </div>
    </form>

    <form style="margin-top:15px ;" method="post" enctype="multipart/form-data" id="filesPlain" class="mb-3">
        <div class="row">

            <div class="form-group row">

                <div class="col-sm-6">
                    <input type="file" required id="file" name="file" class="form-control">
                </div>
               


                <div class="col-md-1">
                    <button type="submit" id="buttonImportar" class="btn" name="import_data"
                        value="Importar">Importar</button>
                </div>

                <div class="col-md-1">
                    <button type="button" title="Descargar Plantilla" id="Plantilla" class="btn btn-primary" name="import_data"
                        value="Plantilla">Plantilla</button>
                </div>

            </div>

        </div>
    </form>
    <div class="col-12" id="divTabla">
        <table border="1" class="table table-bordered mt-3" id="tablaprueba">
            <thead style="background-color: #0D729C;color: white;">
                <tr>
                    <th>Quitar</th>
                    <th>Producto</th>
                    <th>Nombre</th>
                    <th>Observación</th>
                    <th>Cantidad</th>
                    <th>Precio Uni</th>
                    <!-- <th class="Val-Pre">Precio Uni oi</th> -->
                    <!-- <th class="tides">Tip Desc</th> -->
                    <!-- <th class="tides">Descuento</th>
                    <th class="tides">Val Descuento</th> -->
                    <!-- <th class="Val-Pre">Valor Total</th> -->
                    <th>Valor Total</th>
                    <th>Impuestos</th>
                </tr>
            </thead>
            <tbody id="tbody">
            </tbody>
        </table>
    </div>
    <div class="form-group mt-4">
        <button type="button" class="btn btn-primary mr-2" onclick="agregarFila()" style="background-color: #0b5ed7; color: white;">Agregar Item</button>
        <button type="button" class="btn btn-danger" onclick="eliminarFila()" style="background-color: #dc3545; color: white;">Eliminar Item</button>
        <button type="button" class="btn" onclick="eliminarFillasAll()" style="background-color: #df6219; color: white;">Limpiar Tabla</button>
    </div>
    <div class="col-12" id="DivTab">
        <table class="table table-bordered mt-3">
            <thead>
                <tr>
                    <th  scope="col" id="subtotal" class="tides" style="text-align:right;">SubTotal
                        <input  style="text-align:right;" class="form-control" type="text" id="subtota" placeholder="$" disabled>
                    </th>
                    <th scope="col" id="ImpuIva" class="tides" style="text-align:right;">Impuestos
                        <input  style="text-align:right;" class="form-control"type="text" id="ImpuesIva" placeholder="$" disabled>
                    </th>
                    <th scope="col" id="GeneDescuentos" class="tides" style="text-align:right;">Descuentos
                        <input style="text-align:right;" class="form-control" type="text" id="DescGene" placeholder="$" disabled></th>
                    <th scope="row" id="total" style="text-align:right;">Valor Total
                        <input style="text-align:right;" class="form-control" type="text" id="ValTota" placeholder="$" disabled>
                    </th>
                </tr>
            </thead>
        </table>
    </div>
    <div class="col-12">
        <button type="button" id="button" class="btn" onclick="guardarPedido()">Guardar</button>
        <button type="button"  class="btn btn-primary"  onclick="guardarCotizacion()">Cotización</button>

        <?php
            if (isset($_POST['CodCarr'])) {
                ?>
                    <button type="button" id="button" class="btn CarAct" onclick="BorrarCarrito()">Borrar Carrito</button>
                    <!-- <button type="button" id="PDF"  class="btn btn-primary">PDF</button> -->
                <?php
 
            }

        ?>
     
    </div>

    <div id="ModalPedido">

    </div>

</div>



<?php


include 'homebott.php';

    ?>
<script src="../../js/mantenimiento.js"></script>
<script src="../../js/form.js"></script>
<script src="../../js/CreatePedido.js"></script>
<script src="../../js/Modalidades.js"></script>
<script src="../../js/CreateDiviPol.js"></script>
<script src="../../js/CabezaPedido.js"></script>
<script src="../../js/CreateFPago.js"></script>
<script src="../../js/CreateRDes.js"></script>
<script src="../../js/ArchivoPlano.js"></script>
<script src="../../js/CopiaPedido.js"></script>
<!-- <script src="../../js/Carrito.js"></script> -->
<script src="../../js/LoadDetCarri.js"></script>
<script src="../../js/ImpIVA.js"></script>

<script src="../../js/Cotizacion.js"></script>
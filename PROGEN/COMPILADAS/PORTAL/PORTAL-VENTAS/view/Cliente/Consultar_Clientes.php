<?php
error_reporting(0);
require_once("../../controller/verification/functions.php");
session_start();

valida_sesion();

$start_time = microtime(true);
include '../../controller/api/ws_verify_clien.php';
$end_time = microtime(true);
$duration = $end_time - $start_time;
$hours = (int)($duration/60/60);
$minutes = (int)($duration/60)-$hours*60;
$seconds = (int)$duration-$hours*60*60-$minutes*60; 
// echo "Tiempo empleado para cargar esta pagina: <strong>" . $hours.' horas, '.$minutes.' minutos y '.$seconds.' segundos.</strong>';


// ECHO $_SESSION['CrePedVent'];
// echo $_SESSION['URL'];
include 'homeTop.php';
?>

<head>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.19/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" type="text/css" href="../../css/Ver_Productos.css">
    <link rel="stylesheet" href="../../css./fuente_raleway.css">
    <script src="https://code.jquery.com/jquery-3.3.1.js"></script>
    <script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.19/js/dataTables.bootstrap4.min.js"></script>
    <script src="../../Alert/dist/sweetalert2.all.min.js"></script>
    <script src="../../Alert/dist/sweetalert2.min.js"></script>
    <link rel="stylesheet" href="../../Alert/dist/sweetalert2.min.css">
</head>

<div class="container-fluid p-5 row">
    <div class="col-12 mb-4" id="divTitulo">
        <h4 style="font-size: 27px;">Clientes</h4>
    </div>
    <div id="coverScreen" class="LockOn">
        <!-- <div class="loader-text"></div> -->
    </div>



    <div class="col-12 mb-4">
        <button type="button" id="buttonGenerar" style="background-color: #30bb37;color: white;border-color: #3dc731;"
            disabled class="btn">Generar Pedido</button>
        <button type="button" id="buttonConsultar" disabled class="btn btn-primary">Consultar Pedidos</button>
        <!-- <button type="button" id="buttonProductos" style="background-color: #df6219;color: white;border-color: #d66921;"
            disabled class="btn btn-success">Consultar Productos</button> -->
    </div>


    <div class="container-fluid ViewClie">
        <table id="example" class="table table-striped table-bordered" style="width:100%">
            <thead id="encabezadoTabla">
                <tr>
                    <th></th>
                    <th>Código</th>
                    <th>Nombre</th>
                    <th>Tienda</th>
                    <th>Dirección</th>
                    <th>Email</th>
                    <th>Teléfono</th>
                    <th>Detalle</th>
                </tr>
            </thead>
            <tbody>
                <?php
                if (isset($_SESSION['clientes'])) {
                    $cont = 0;
                    foreach ($_SESSION['clientes'] as $clie) {
                        $cont++;
                        echo '<tr>';
                        echo '<td><input type="radio" name="clien" class="Clien" value="' . $clie['code'] . '??' . $clie['pricelist'].'??'.$clie['store'].'" id="radio' . $cont . '"></td>';
                        echo '<td>' . $clie['code'] . '</td>';
                        echo '<td>' . $clie['namefan'] . '</td>';
                        echo '<td>' . $clie['store'] . '</td>';
                        echo '<td>' . $clie['customeraddress'] . '</td>';
                        echo '<td>' . $clie['email'] . '</td>';
                        echo '<td>' . $clie['phone'] . '</td>';
                        echo '<td><button type="button" class="btn" data-bs-toggle="modal" data-bs-target="#exampleModal' . $cont . '">
                                <img src="../../img/lupa.png" alt="ver" width="20px">
                                </button></td>';


                        echo '</tr>';


                        echo '</tr>';

                    }
                }
                ?>

            </tbody>
        </table>
    </div>
</div>


<?php
if (isset($_SESSION['clientes'])) {
    $cont = 0;
    foreach ($_SESSION['clientes'] as $clien) {
        $cont++;
        echo '
         <div class="modal fade" id="exampleModal' . $cont . '" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
             <div class="modal-dialog modal-lg">
                 <div class="modal-content">
                     <div class="modal-header">
                         <h1 class="modal-title fs-5" id="exampleModalLabel">Detalle Cliente</h1>
                         <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                     </div>
                     <div class="modal-body">
                         <div class="row">
                             <div class="col-md-2">
                                 <label for="">Nombre</label>
                             </div>
                             <div class="col-md-6">
                                 <input type="text" class="form-control" placeholder="' . $clien['name'] . '" disabled>
                             </div>
                             <div class="col-md-2">
                                 <label for="">Sucursal</label>
                             </div>
                             <div class="col-md-2">
                                 <input type="number" class="form-control" placeholder="' . $clien['store'] . '" disabled>
                             </div>
                         </div>
                     </div>
                     <div class="modal-footer">
                         <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                     
                     </div>
                 </div>
             </div>
         </div>
        ';
    }
}
?>

<script>

    var table = $('#example').DataTable({});

    //Creamos una fila en el head de la tabla y lo clonamos para cada columna
    $('#example thead tr').clone(true).appendTo('#example thead');

    $('#example thead tr:eq(1) th').each(function (i) {

        $(this).html('<input type="text" class="form-control" />');

        $('input', this).on('keyup change', function () {
            if (table.column(i).search() !== this.value) {
                table
                    .column(i)
                    .search(this.value)
                    .draw();
            }
        });
    });


    $("#example").dataTable().fnDestroy();


    $('#example').dataTable({
        language: {
            "sProcessing": "Procesando...",
            "sLengthMenu": "Mostrar _MENU_ Registros",
            "sZeroRecords": "No se encontraron resultados",
            "sEmptyTable": "Ningún dato disponible en esta tabla",
            "sInfo": "Mostrando registros del _START_ al _END_ de un total de _TOTAL_ registros",
            "sInfoEmpty": "Mostrando registros del 0 al 0 de un total de 0 registros",
            "sInfoFiltered": "(filtrado de un total de _MAX_ registros)",
            "sInfoPostFix": "",
            "sSearch": "Buscar:",
            "sUrl": "",
            "sInfoThousands": ",",
            "sLoadingRecords": "Cargando...",
            "oPaginate": {
                "sFirst": "Primero",
                "sLast": "Último",
                "sNext": "Siguiente",
                "sPrevious": "Anterior"
            },
            "oAria": {
                "sSortAscending": ": Activar para ordenar la columna de manera ascendente",
                "sSortDescending": ": Activar para ordenar la columna de manera descendente"
            },
            "buttons": {
                "copy": "Copiar",
                "colvis": "Visibilidad"
            }
        }
    });
</script>

<?php
include 'homebott.php'
    ?>
<script src="../../js/mantenimiento.js"></script>
<script src="../../js/LoadClien.js"></script>
<!-- <script src="../../js/Modalidades.js"></script> -->
<script src="../../js/CreateDiviPol.js"></script>
<script src="../../js/CreateFPago.js"></script>
<script src="../../js/CreateRDes.js"></script>
<script src="../../js/ImpIVA.js"></script>
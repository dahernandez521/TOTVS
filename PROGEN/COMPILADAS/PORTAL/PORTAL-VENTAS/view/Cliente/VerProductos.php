<?php
error_reporting(0);
require_once("../../controller/verification/functions.php");
session_start();

valida_sesion();

valida_clien();

// include '../../controller/api/ws_verify_DetClien.php';
//    include '../../ws_verify_produ.php';

include 'homeTop.php';

?>

<head>
    <meta charset="utf-8" />
    <title></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.css">
    <link rel="stylesheet" href="https://cdn.datatables.net/1.10.19/css/dataTables.bootstrap4.min.css">
    <link rel="stylesheet" type="text/css" href="../../css/Ver_Productos.css">
    <link rel="stylesheet" href="../../css./fuente_raleway.css">

    <script src="../../Alert/dist/sweetalert2.all.min.js"></script>
    <script src="../../Alert/dist/sweetalert2.min.js"></script>
    <link rel="stylesheet" href="../../Alert/dist/sweetalert2.min.css">

    <script src="https://code.jquery.com/jquery-3.3.1.js"></script>
    <script src="https://cdn.datatables.net/1.10.19/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.10.19/js/dataTables.bootstrap4.min.js"></script>
    <script src="../../js/CargueProd.js"></script>
</head>
<div class="container-fluid p-5 row">
    <div class="col-12 mb-3" id="divTitulo">
        <h4 style="font-size: 27px;">Productos <img src="../../img/refresh.png" id="Refresh"  <?php if(isset($_SESSION["UltConsProd"])){echo 'title="Actualizado el: '.$_SESSION["UltConsProd"].'"';} ?> alt="Refrescar" width="3%"></h4>
        
    </div>

    <div id="ScreenProd" class="LockOn">
    </div>

    <div class="container-fluid">
        <table id="example" class="table table-striped table-bordered" style="width:100%">
            <thead style="background-color: #0D729C;color: white;">
                <tr>
                    <th>Código</th>
                    <th>Descripción</th>
                    <th>Ref Cruzada</th>
                    <th>Desc Cliente</th>
                    <th>Detalle</th>
                    <th>Carrito</th>
                </tr>
            </thead>
            <tbody>
                <?php
                if (isset($_SESSION["productos_obj"])) {

                    if (!empty($_SESSION["productos_obj"])) {
                        $ImpProd = null;
                        $option = null;

                        $cont = 0;

                        if (isset($_SESSION['ImpProd']) && strlen($_SESSION['ImpProd']) > 5) {
                            echo $_SESSION['ImpProd'];
                        } else {

                            foreach ($_SESSION["productos_obj"] as $detalle) {
                                if ($_SESSION["L_preci"] === $detalle["code_lp"]) {
                                    $RefCruz = "";
                                    $DesClie = "";

                                    if (isset($_SESSION['RCruz'])) {
                                        foreach ($_SESSION['RCruz'] as $ref) {
                                            if (trim($ref['cliente'] === trim($_SESSION['Cliente']))) {
                                                if (trim($ref['codepro']) === trim($detalle["code"])) {
                                                    $RefCruz = $ref['codecli'];
                                                    $DesClie = $ref['descripcli'];
                                                    // $DesClie = "<input id>";
                                                    break;
                                                }
                                            }
                                        }
                                    }

                                    $ImpProd .= '<tr>';
                                    $ImpProd .= '<td>';
                                    $ImpProd .= $detalle["code"];
                                    $ImpProd .= '</td>';
                                    $ImpProd .= '<td>';
                                    $ImpProd .= $detalle["name"];
                                    $ImpProd .= '</td>';


                                    $ImpProd .= '<td>';
                                    $ImpProd .= $RefCruz;
                                    $ImpProd .= '</td>';

                                    $ImpProd .= '<td>';
                                    $ImpProd .= $DesClie;
                                    $ImpProd .= '</td>';



                                    $ImpProd .= '<td>';
                                    $ImpProd .= '<button type="button" class="btn" data-bs-toggle="modal" data-bs-target="#DE' . $detalle['item'] . '">
                                                <img src="../../img/lupa.png" alt="ver" width="20px">
                                            </button>';
                                    $ImpProd .= '</td>';

                                    $ImpProd .= '<td>';
                                    $ImpProd .= '<button type="button" class="btn" data-bs-toggle="modal" data-bs-target="#CA' . $detalle['item'] . '">
                                                    <img src="../../img/carrito.png" alt="ver" width="20px">
                                                </button>';
                                    $ImpProd .= '</td>';


                                    $ImpProd .= ' </tr>';



                                    $cont++;
                                    if (isset($detalle['StockAct'])) {
                                        $stock = $detalle['StockAct'];
                                    } else {
                                        $stock = 0;
                                    }

                                    $option .= ' <div class="modal fade" id="DE' . $detalle['item'] . '" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title" id="exampleModalLabel">DETALLE</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                        Codigo: ' . $detalle['code'] . '
                                        <br>
                                        Nombre: ' . $detalle['name'] . '
                                        <br>
                                        Precio: $' . number_format($detalle['saleprice'], 2, ',', '.') . '
                                        ';
                                        if(isset($_SESSION['CodVen'])){
                                            $option .= '<br>
                                            Cant Disp: ' . $stock . '
                                            ';
                                        }
                                        
                                        $option .='
                                    
                                    </div>
                                    <div class="modal-footer">
                                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                        <!--  <button type="button" class="btn btn-primary">Save changes</button> -->
                                    </div>
                                </div>
                            </div>
                        </div>';




                                    $option .= '<div class="modal fade" id="CA' . $detalle['item'] . '" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header" style="background-color: #0D729C">
                                            <h5 class="modal-title" id="exampleModalLabel">CARRITO</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                        </div>
                                        <div class="modal-body">
                                            <form style="margin-top:15px ;" method="post"  id="Carrito' . $cont . '" class="mb-3">
                                                <div row g-3 align-items-center>
                                                    <h5 class="modal-title mb-5 pb-3" style="border-bottom: 1px solid;color: #848587;">Información Producto</h5>
                                                    <div class="row mb-4">
                                                        <label class="col-sm-3 col-form-label">Nombre</label>
                                                        <div class="col-sm-9">
                                                            <input type="text" required disabled value="' . $detalle['name'] . '" autocomplete="off" class="form-control" id="name' . $cont . '" name="delim" >
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="row mb-4">  
                                                        <label for="delim" class="col-sm-3 col-form-label">Producto</label>
                                                        <div class="col-sm-9">
                                                            <input type="text" required disabled value="' . $detalle['code'] . '" autocomplete="off" class="form-control" id="prod' . $cont . '" name="delim" >
                                                        </div>
                                                    </div>

                                                    <div class="row mb-4">  
                                                    <label for="delim" class="col-sm-3 col-form-label">Precio</label>
                                                    <div class="col-sm-9">
                                                        <input type="text" required disabled value=$' . number_format($detalle['saleprice'], 2, ',', '.') . ' autocomplete="off" class="form-control" id="Preci' . $cont . '" name="delim" >
                                                    </div>
                                                </div>

                                        
                                                    <div class="row mb-4">
                                                        <label for="delim" class="col-sm-3 col-form-label">Observación</label>
                                                        <div class="col-sm-9">
                                                            <input type="text" value="" autocomplete="off" class="form-control" id="Obs' . $cont . '" name="Obs" >
                                                        </div>
                                                    </div>


                                                  
                                                    

                                                    <div class="row mb-4">
                                                        <label for="delim" class="col-sm-3 col-form-label">Cantidad</label>
                                                        <div class="col-sm-9">
                                                            <input type="number" required  value="1" autocomplete="off" class="form-control" id="cant' . $cont . '" name="delim" >
                                                        </div>
                                                    </div>
                                                </div>
                                            </form>
                                        </div>
                                        <div class="modal-footer">
                                            <button type="button" onclick="carrito(' . $cont . ')" class="btn btn-primary" data-bs-dismiss="modal">Añadir</button>
                                            <!--  <button type="button" class="btn btn-primary">Save changes</button> -->
                                        </div>
                                    </div>
                                </div>
                            </div>';
                                }
                            }

                            $_SESSION['ModProd'] = $option;
                            $_SESSION['ImpProd'] = $ImpProd;
                            echo $ImpProd;

                        }
                    }
                }

                ?>
            </tbody>
        </table>
    </div>
</div>
<div id="modale">

</div>

<?php
if (isset($_SESSION["productos_obj"])) {
    if (!empty($_SESSION["productos_obj"])) {


        if (isset($_SESSION['ModProd']) && strlen($_SESSION['ModProd']) > 5) {
            $option = $_SESSION['ModProd'];

        }
        echo $option;
        echo '<script>
                   
            $("#ScreenProd").hide();
            </script>';
    } else {

        echo '<script>
               
        $("#ScreenProd").hide();
        </script>';
    }
} else {

    echo '<script>
           
    $("#ScreenProd").hide();
    </script>';
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
<script src="../../js/Refresh.js"></script>
<script src="../../js/mantenimiento.js"></script>
<script src="../../js/CreateDiviPol.js"></script>
<script src="../../js/Carrito.js"></script>
<script src="../../js/ImpIVA.js"></script>
<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{
    $datos=null;

    if(isset($_POST['Modal'])){

            $cont=0;
            foreach($_SESSION['clientes'] as $clien){
                $cont ++;
                $datos.='
                 <div class="modal fade" id="exampleModal'.$cont.'" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
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
                                         <input type="text" class="form-control" placeholder="'.$clien['namefan'].'" disabled>
                                     </div>
                                     <div class="col-md-2">
                                         <label for="">Tienda</label>
                                     </div>
                                     <div class="col-md-2">
                                         <input type="number" class="form-control" placeholder="'.$clien['store'].'" disabled>
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

    return($datos);

}
;

echo consulta();
?>
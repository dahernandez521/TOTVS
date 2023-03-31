<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{


    $Antiguo=$_POST['ClAnti'];
    $Nuevo=$_POST['ClNuevo'];
    $observacion=$_POST['Observa'];
    $datos=null;
    $option=null;
    $_SESSION["ClienteFina"]=$Nuevo;

    

    include '../../controller/api/ws_verify_ReNego.php';


        foreach ($_SESSION['clientes'] as $key => $Detalle) {
        
            if (trim($Detalle['code']) === $Nuevo) {

            if ($Detalle['store'] === $_SESSION['Loja']) {

                $Fpago = $Detalle['paymentterms'];
                include 'FormasPago.php';

                $datos =
                    '<div class="col-md-3">
                    <label for="inputIdCliente" class="form-label">Id Cliente</label>
                    <input type="text" class="form-control" id="inputIdCliente" placeholder="' . $Antiguo . '" disabled value="' . $Antiguo . '">
                </div>
    
                <div class="col-md-3">
                <label for="NumIdenTwo" class="form-label">Cliente Final</label>
                <input type="text" id="NumIdenTwo" autocomplete="off" class="form-control" required onchange="SelClien()" list="Clien-list" value="' . trim($Detalle['code']) . '">
                <datalist id="Clien-list" class="lista_Clien">
    
                </datalist>
                </div>
    
                <div class="col-md-6">
                    <label for="inputCliente" class="form-label">Cliente</label>
                    <input type="number" class="form-control" id="inputCliente" placeholder="' . $Detalle['namefan'] . '" disabled>
                </div>
                <div class="col-md-1">
                    <label for="inputSucursal" class="form-label">Tienda</label>
                    <input type="number" class="form-control" id="inputSucursal" placeholder="' . $Detalle['store'] . '" disabled>
                </div>
                <div class="col-md-3">
                    <label for="inputDireccion" class="form-label">Dirección de entrega</label>
                    <input type="text" class="form-control" id="inputDireccion"  value="' . trim($Detalle['direntrega']) . '">
                </div>
    
    
                <div class="col-md-4 mt-2">
                <label for="Departamento" class="form-label">Departamento entrega</label>
                <select disabled type="text" class="form-control" id="Departamento" placeholder="" >
                <option >' . $Detalle['depa'] . '</option>
                </select> 
                </div>
    
    
                <div class="col-md-4 mt-2">
                <label for="municipio" class="form-label">Municipio entrega</label>
                <select type="text" class="form-control" id="Municipio" placeholder="" >
                <option >' . $Detalle['muni'] . '</option>
                </select> 
                </div>
    
              
    
    
                <div class="col-md-2 mt-2">
                <label for="inputCondicion" class="form-label">Condición de pago</label>
                <select disabled type="text" class="form-control" id="inputCondicion" placeholder="" >
                ' . $option . '                
                </select> 
                </div>
    
                <div class="col-md-4 mt-2">
                    <label for="Modalidad" class="form-label">Modalidad</label>
                    <select type="text" class="form-control" id="Modalidad" placeholder="" >
                    <option >' . $Detalle['modalidad'] . '</option>
                    </select> 
                </div>
               
                <div class="col-md-2 mt-2">
                    <label for="inputLimite" class="form-label">Límite Crédito</label>
                    <input type="text" class="form-control" id="inputLimite" placeholder="' . $Detalle['creditlimit'] . '" disabled>
                </div>
                <div class="col-md-2 mt-2">
                    <label for="inputLista" class="form-label">Lista de Precio</label>
                    <input type="text" class="form-control" id="inputLista" placeholder="' . $Detalle['pricelist'] . '" disabled>
                </div>
           
                <div class="col-md-2 mt-2 tides" >
                    <label for="inputDescuento" class="form-label">Descuento %</label>
                    <input type="number" id="DesGene" onkeyup="CalcuDesGene()" class="form-control" value="' . $Detalle['descuent'] . '" placeholder="' . $Detalle['descuent'] . '" >
                </div>
    
             
                <div class="col-md-12 mt-2">
                    <label for="Descripción" class="form-label">Observación</label>
                    <textarea class="form-control" id="Descripcion" >' . $observacion . '</textarea>
                </div>
                ';


                break;
            }
            }
        }

    

    return ($datos);


}
;

echo consulta();
?>
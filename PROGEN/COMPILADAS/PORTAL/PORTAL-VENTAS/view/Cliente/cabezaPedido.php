<?php

if (isset($_SESSION['Cliente'])) {
    // echo $_SESSION['Cliente']; 
    date_default_timezone_set("America/Bogota");


    foreach ($_SESSION['clientes'] as $key => $Detalle) {
        
        if ($Detalle['code'] === $_SESSION['Cliente']) {

     
            // if (isset($_SESSION["DetPedido"])) {
            //     $date = new DateTime($_SESSION["DetPedido"]['emitiondate']);
            //     $date = $date->format('d-m-Y');


                echo '
            <div class="col-md-3">
            <label for="code" class="form-label">N° Pedido</label>
            <input type="number" class="form-control" id="code" placeholder="' . $_SESSION['DetPed'] . '" disabled>
            </div>

            <div class="col-md-3">
                <label for="date" class="form-label">Fecha</label>
                <input type="text" class="form-control" disabled id="date" placeholder="">
            </div>
        
            <div class="col-md-3">
                <label for="inputIdCliente" class="form-label">Id Cliente</label>
                <input type="number" class="form-control" id="inputIdCliente" placeholder="' . $Detalle['code'] . '" disabled>
            </div>

            <div class="col-md-6">
                <label for="NumIdenTwo" class="form-label">Cliente Entrega</label>
                <input type="number" class="form-control" id="NumIdenTwo" placeholder="' . $Detalle['code'] . '" disabled>
            </div>

            <div class="col-md-5">
                <label for="inputCliente" class="form-label">Cliente</label>
                <input type="number" class="form-control" id="inputCliente" placeholder="' . $Detalle['name'] . '" disabled>
            </div>

            <div class="col-md-12 mt-2">
                <label for="inputDireccion" class="form-label">Dirección de entrega</label>
                <input type="number" class="form-control" id="inputDireccion" placeholder="' . $Detalle['direntrega'] . '" disabled>
            </div>
            
            <div class="col-md-3">
                <label for="inputSucursal" class="form-label">Tienda</label>
                <input type="number" class="form-control" id="inputSucursal" placeholder="' . $Detalle['store'] . '" disabled>
            </div>
            

            <div class="col-md-5">
                <label for="Departamento" class="form-label">Departamento entrega</label>
                <input type="text" class="form-control" id="Departamento"  value="' . $Detalle['nomdepentre'] . '" disabled>
            </div>

            <div class="col-md-5">
                <label for="municipio" class="form-label">Municipio entrega</label>
                <input type="text"  class="form-control" id="municipio"  value="' . $Detalle['nommunentre'] . '" disabled>
            </div>

            <div class="col-md-2 mt-2">
                <label for="inputCondicion" class="form-label">Condición de pago</label>
                <input type="text" class="form-control" id="inputCondicion" placeholder="' . $Detalle['paymentterms'] . '" disabled>
            </div>

            <div class="col-md-2 mt-2">
                <label for="Modalidad" class="form-label">Modalidad df</label>
                <input type="text" class="form-control" id="Modalidad" placeholder="' . $Detalle['modalidad'] . '" disabled>
            </div>
   

            <div class="col-md-2 mt-2">
                <label for="inputLimite" class="form-label">Límite Crédito</label>
                <input type="text" class="form-control" id="inputLimite" placeholder="' . $Detalle['creditlimit'] . '" disabled>
            </div>
            <div class="col-md-2 mt-2">
                <label for="inputLista" class="form-label">Lista de Precio</label>
                <input type="text" class="form-control" id="inputLista" placeholder="' . $Detalle['pricelist'] . '" disabled>
            </div>
            <div class="col-md-8 mt-2">
                <label for="Descripción" class="form-label">Observación</label>
                <textarea class="form-control" id="Descripcion" disabled placeholder="' . $Detalle['customeraddress'] . '"></textarea>
            </div>

            ';
            // }else{
            //     echo "---no hay detalle de pedido";
            // }
            break;
        }
    }
}else

?>
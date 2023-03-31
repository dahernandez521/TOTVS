<?php

if (isset($_SESSION['Cliente'])) {
    // echo $_SESSION['Cliente']; 
    date_default_timezone_set("America/Bogota");

    foreach ($_SESSION['clientes'] as $key => $Detalle) {
        if ($Detalle['code'] === $_SESSION['Cliente']) {
            if ($Detalle['store'] === $_SESSION['Loja']) {
                $_SESSION['Modalidad'] = $Detalle['modalidad'];
                $_SESSION['Departamento'] = $Detalle['depa'];
                $_SESSION['NomDept'] = $Detalle['depdirentre'];
                $_SESSION['Municipio'] = $Detalle['muni'];
                $_SESSION['NomMuni'] = $Detalle['nommunentre'];
                $_SESSION['namefan'] = $Detalle['namefan'];
                $_SESSION['SalDeb'] = $Detalle['totaldeb'];
                $_SESSION['SalCre'] = $Detalle['totalcre'];
                $_SESSION['Saldo'] = $Detalle['creditlimit'] - ($_SESSION['SalDeb'] - $_SESSION['SalCre']);




                echo '
            <div class="row" id="CabezaPedi">
            <div class="col-md-3">
                <label for="inputIdCliente" class="form-label">Id Cliente</label>
                <input type="text" class="form-control" id="inputIdCliente" placeholder="' . $Detalle['code'] . '" disabled value="' . $Detalle['code'] . '">

                </div>

            <div class="col-md-3">
            <label for="NumIdenTwo"  class="form-label">Cliente Entrega</label>
            <input type="text" id="NumIdenTwo" disabled autocomplete="off" class="form-control" required onchange="SelClien()"  list="Clien-list" value="' . trim($Detalle['code']) . '">
            <datalist disabled id="Clien-list" class="lista_Clien"></datalist>
            </div>

            <div class="col-md-6">
                <label for="inputCliente" class="form-label">Cliente</label>
                <input type="number" class="form-control" id="inputCliente" placeholder="' . $Detalle['namefan'] . '" disabled>
            </div>

            <div class="col-md-12 mt-2">
                <label for="inputDireccion" class="form-label">Dirección de entrega</label>
                <input type="text" class="form-control" id="inputDireccion"  value="' . trim($Detalle['direntrega']) . '">
            </div>

           
            

            <div class="col-md-4 mt-2">
            <label for="Departamento" class="form-label">Departamento entrega</label>
            <select type="text" disabled class="form-control" id="Departamento" placeholder="" >
            <option >' . $Detalle['depa'] . '</option>
            </select> 
            </div>

            <div class="col-md-4 mt-2">
            <label for="Municipio" class="form-label">Municipio entrega</label>
            <select type="text" class="form-control" id="Municipio" placeholder="" >
            <option >' . $Detalle['muni'] . '</option>
            </select> 
            </div>

        
            <div class="col-md-4 mt-2">
            <label for="inputCondicion" class="form-label">Condición de pago</label>
            <select disabled type="text" class="form-control" id="inputCondicion" placeholder="" >
            <option id="' . $Detalle['code'] . '" value="' . $Detalle['code'] . '"  >' . $Detalle['paymentterms'] . '</option>
            </select> 
            </div>

            <div class="col-md-1">
            <label for="inputSucursal" class="form-label">Tienda</label>
            <input type="number" class="form-control" id="inputSucursal" placeholder="' . $Detalle['store'] . '" disabled>
        </div>

            <div class="col-md-5 mt-2">
                <label for="Modalidad" class="form-label">Modalidad</label>
                <select disabled type="text" class="form-control" id="Modalidad" placeholder="" >
                <option >' . $Detalle['modalidad'] . '</option>
                </select> 
            </div>
           
            <div class="col-md-2 mt-2">
                <label for="inputLimite" class="form-label">Cupo Disponible</label>
                <input type="text" class="form-control" id="inputLimite" placeholder="$ ' . number_format($_SESSION['Saldo'], 3, ',', '.') . '" disabled>
            </div>
            <div class="col-md-2 mt-2">
                <label for="inputLista" class="form-label">Lista de Precio</label>
                <input type="text" class="form-control" id="inputLista" placeholder="' . $Detalle['pricelist'] . '" disabled>
            </div>
       
            <div class="col-md-2 mt-2 tides" >
                <label for="inputDescuento" class="form-label">Descuento %</label>
                <input type="number" id="DesGene" disabled onkeyup="CalcuDesGene()" class="form-control" value="' . $Detalle['descuent'] . '" placeholder="' . $Detalle['descuent'] . '" >
            </div>

            <div class="col-md-12 mt-2">
                <label for="Descripción" class="form-label">Observación</label>
                <textarea class="form-control" id="Descripcion" ></textarea>
            </div>
            </div>
            ';
                break;
            }
        }
    }
}
?>
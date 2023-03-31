<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{


    $option = null;
    $ClienEnt = null;
    $Municipio = null;
    $Departamento = null;
    $modalidad = null;
    $ClienGene = null;
    $CodFp=null;
    $NomFp = null;


    if (isset($_SESSION["Pedidos"])) {
        foreach ($_SESSION["Pedidos"] as $Detalle) {
            if ($Detalle['code'] == $_SESSION['DetPed']) {

                foreach ($_SESSION['clientes'] as $key => $Entre) {


                    if ((trim($Entre['code'])) === (trim($Detalle['codclientent']))) {

                        $ClienEnt = $Entre['namefan'];
                        $pricelist = $Entre['pricelist'];

                        break;

                    }
                }


                foreach ($_SESSION['clientes'] as $key => $Entre) {


                    if ((trim($Entre['code'])) === (trim($Detalle['codclient']))) {

                        $ClienGene = $Entre['namefan'];

                        break;

                    }
                }

                foreach ($_SESSION["Municipios"] as $Muni) {
                    if ((trim($Muni['code'])) === (trim($Detalle['codmun']))) {
                        $Municipio = $Muni['descsri'];
                        break;
                    }
                }


                foreach ($_SESSION["Departamentos"] as $Depa) {
                    if ((trim($Depa['code'])) === (trim($Detalle['depto']))) {
                        $Departamento = $Depa['descsri'];
                        break;
                    }

                }

                if (isset($_SESSION["Modalidades"])) {
                    foreach ($_SESSION["Modalidades"] as $moda) {

                        if ((trim($moda['code'])) === (trim($Detalle['modalidad']))) {
                            $modalidad = $moda['descsri'];
                            break;
                        }

                    }
                }

                if (isset($_SESSION["Fpago"])) {
                    foreach ($_SESSION["Fpago"] as $Fpa) {

                        if (trim($Fpa['code']) === (trim($Detalle['paymentterms']))) {
                            $CodFp = $Fpa['code'];
                            $NomFp = $Fpa['name'];


                        }
                    }
                }
    

                $date = new DateTime($Detalle['emitiondate']);
                $date = $date->format('d/m/Y');

                $option = '
                     
                    <div class="col-md-2">
                        <label for="code" class="form-label">N° Pedido</label>
                        <input type="number" class="form-control" id="code" placeholder="' . $Detalle['code'] . '" disabled>
                    </div>

                    <div class="col-md-2">
                        <label for="date" class="form-label">Fecha</label>
                        <input type="text" class="form-control"  disabled id="date" placeholder="' . $date . '">
                    </div>

                    <div class="col-md-3">
                        <label for="inputIdCliente" class="form-label">Id Cliente</label>
                        <input type="number" class="form-control" id="inputIdCliente" placeholder="' . $Detalle['codclient'] . '" disabled>
                    </div>

                    <div class="col-md-5">
                        <label for="inputCliente" class="form-label">Cliente</label>
                        <input type="number" class="form-control" id="inputCliente" placeholder="' . $ClienGene . '" disabled>
                    </div>

                    <div class="col-md-3">
                        <label for="NumIdenTwo" class="form-label">Cliente Entrega</label>
                        <input type="number" class="form-control" id="NumIdenTwo" placeholder="' . $Detalle['codclientent'] . '" disabled>
                    </div>

                    <div class="col-md-6">
                        <label for="inputCliente" class="form-label">Nombre Cliente Entr</label>
                        <input type="number" class="form-control" id="inputCliente" placeholder="' . $ClienEnt . '" disabled>
                    </div>
                    <div class="col-md-3">
                        <label for="inputSucursal" class="form-label">Sucursal</label>
                        <input type="number" class="form-control" id="inputSucursal" placeholder="' . $Detalle['storeent'] . '" disabled>
                    </div>
                    <div class="col-md-4">
                        <label for="inputDireccion" class="form-label">Dirección de entrega</label>
                        <input type="number" title="' . $Detalle['adressent'] . '" class="form-control" id="inputDireccion" placeholder="' . $Detalle['adressent'] . '" disabled>
                    </div>

                    <div class="col-md-4 mt-2">
                        <label for="Departamento" class="form-label">Departamento entrega</label>
                        <input type="text" class="form-control" id="Departamento"  value="' . $Departamento . '" disabled>
                    </div>

                    <div class="col-md-4 mt-2">
                        <label for="municipio" class="form-label">Municipio entrega</label>
                        <input type="text" class="form-control" id="municipio"  value="' . $Municipio . '" disabled>
                    </div>

                    <div class="col-md-4 mt-2">
                        <label for="inputCondicion" class="form-label">Condición de pago</label>
                        <input type="text" class="form-control" id="inputCondicion" placeholder="' . $NomFp . '" disabled>
                    </div>

                    <div class="col-md-4 mt-2">
                        <label for="Modalidad" class="form-label">Modalidad</label>
                        <input type="text" class="form-control" id="Modalidad" placeholder="' . $modalidad . '" disabled>
                    </div>


                    <div class="col-md-4 mt-2">
                        <label for="inputLista" class="form-label">Lista de Precio</label>
                        <input type="text" class="form-control" id="inputLista" placeholder="' . $pricelist . '" disabled>
                    </div>



                    <div class="col-md-12 mt-2">
                        <label for="Descripción" class="form-label">Observación</label>
                        <textarea class="form-control" id="Descripcion" disabled placeholder="' . $Detalle['observaped'] . '"></textarea>
                    </div>';
                break;
            }
        }
    }

    return (($option));


}
;

echo consulta();
?>
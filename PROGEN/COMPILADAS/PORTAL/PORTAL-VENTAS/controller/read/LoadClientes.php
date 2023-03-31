<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{
    $datos=0;
    unset($_SESSION["clientes"]);
    if(isset($_POST['Clientes'])){

        $obj = json_decode($_POST['Clientes'],TRUE);      
        $_SESSION["clientes"]=$obj['ClientxU'];

        $datos = '<table id="example" class="table table-striped table-bordered" style="width:100%">
        <thead>
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

        ';

        $cont=0;
            foreach ($_SESSION["clientes"] as $clie ) {
                $cont ++;
                $datos .= '<tr>
                <td><input type="radio" name="clien" class="Clien" value="'. trim($clie['code']).'??'.$clie['pricelist'].'??'.$clie['store'].'" id="radio'. $cont.'"></td>
                            <td>'. $clie['code'].'</td>
                            <td>'. $clie['namefan']. '</td>
                            <td>'. $clie['store']. '</td>
                            <td>'. $clie['customeraddress']. '</td>
                            <td>'. $clie['email']. '</td>
                            <td>'. $clie['phone']. '</td>
                            <td><button type="button" class="btn" data-bs-toggle="modal" data-bs-target="#exampleModal'.$cont.'">
                                <img src="../../img/lupa.png" alt="ver" width="20px">
                                </button></td>
                </tr>';
            }


        


        $datos .='</tbody>
        </table>';




    }

    if(!isset($_SESSION['clientes'])){
        if (isset($_SESSION['CacheClien'])) {

            $datos=$_SESSION['CacheClien'];
    
        }
    }

    return($datos);

}
;

echo consulta();
?>
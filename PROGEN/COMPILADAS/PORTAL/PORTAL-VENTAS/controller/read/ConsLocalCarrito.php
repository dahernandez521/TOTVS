<?php
error_reporting(0);
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{

    // if (isset($_POST['array'])) {
    //     $array = $_POST['array'];
    //     // $_SESSION['productos_obj']=$array["LisPreDet"];
    //     $obje = json_decode($array, TRUE);


    //     $_SESSION["Carrito"] = $obje;

    // }
    $option = '<table id="Cotizacion" class="table table-striped table-bordered mt-3">
    <thead style="background-color: #0D729C;color: white;">
        <tr>
            <th scope="col">Num Cotización</th>
            <th scope="col">Observación</th>
            <th scope="col"># items</th>
            
            <th scope="col">Fecha de Emision</th>
            <th scope="col">Usuario</th>
            <th scope="col">Usar</th>
            <th scope="col">Imprimir</th>
            <th scope="col">Eliminar</th>
        </tr>
    </thead>
    <tbody id="cuerpoTabla">

    ';

    $Cliente = trim($_SESSION['Cliente']);
    $tienda = $_SESSION['Loja'];

    $name = '1.json';
    $ruta = '../../Cotizaciones/' . $Cliente . "/" . $tienda;
    $arrFiles = glob($ruta . "/*.json");
    $cont = 0;

    $_SESSION["Carrito"] = null;

    foreach ($arrFiles as $files) {

        $num = str_replace($ruta . "/", '', $files);
        $num = str_replace(".json", '', $num);


        $jsonRes = ListarCotizacion($files);


        // $_SESSION["Carrito"].=$jsonRes['Items'];


       
         
            foreach ($jsonRes['Items'] as $item) {
                $cont++;
            }

            $option .= '<tr id="Reg' . $num . '">
                <td>' . $num . '</td>
                <td id="obs' . $num . '">'.$jsonRes['MessageForNote'].'</td>
                <td>' . $cont . '</td>           
                <td id="date' . $num . '">'.$jsonRes['Date'].'</td>
                <td>'.$jsonRes['Usuario'].'</td>
                <td><a id="' . $num . '" onclick="FunCoti(this,1,999,999)"  href="#"><img src="../../img/file.png" title="Crear Pedido" alt="" srcset="" width="20px"></a></td>
                <td><a id="' . $num . '" onclick="FunCoti(this,2,999,999)"  href="#"><img src="../../img/documents.png" title="Imprimir PDF" alt="" srcset="" width="20px"></a></td>
                <td><a id="' . $num . '" onclick="FunCoti(this,3,999,999)"  href="#"><img src="../../img/eliminar.png" title="Eliminar" alt="" srcset="" width="20px"></a></td>
                </tr>';
            $cont = 0;
        

    }





    $option .= '</tbody>
        </table>';

    return ($option);


}
;

function ListarCotizacion($ruta)
{

    if (file_exists($ruta)) {
        $Cotizacion = file_get_contents($ruta);
        $Cotizacion = json_decode($Cotizacion, true);
        // $name = $decoded_json['Client'];
        // $countries = $decoded_json['Items'];
        // foreach ($countries as $country) {
        //     echo $name . ' visited ' . $country['Product'] . ' in ' . $country['SalesQuantity'] . '.' . "<br>";
        // }
    } else {
        $Cotizacion = '9999';
    }
    return $Cotizacion;
}

echo consulta();
?>
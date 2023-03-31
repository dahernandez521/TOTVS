<?php
// error_reporting(0);
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{

    $Cliente = trim($_SESSION['Cliente']);
    $tienda = $_SESSION['Loja'];

    $name = '1.json';
    $ruta = '../../Cotizaciones/' . $Cliente . "/" . $tienda;
    $arrFiles = glob($ruta . "/*.json");
    $cont = 0;

    $_SESSION["Carrito"] = null;


    $dat = array();
    $response = array();

    foreach ($arrFiles as $files) {

        $num = str_replace($ruta . "/", '', $files);
        $num = str_replace(".json", '', $num);


        $jsonRes = ListarCotizacion($files);


        foreach ($jsonRes['Items'] as $item) {
            $cont++;
        }


        $fechaInicio = new DateTime($jsonRes['Date']);
        $fechaFin = new DateTime();
        $intervalo = $fechaInicio->diff($fechaFin);
        $dias = $intervalo->d;

        if ($dias <= 15) {

            $response['DT_RowId'] = "Reg" . $num;
            $response['num'] = $num;
            $response['MessageForNote'] = $jsonRes['MessageForNote'];
            $response['cant'] = $cont;
            $response['date'] = $jsonRes['Date'];
            // $response['dpen'] = $intervalo->d;
            $response['Usuario'] = $jsonRes['Usuario'];
            $response['pedido'] = '<a id="' . $num . '" onclick="FunCoti(this,1,999,999)"  href="#"><img src="../../img/file.png" title="Crear Pedido" alt="" srcset="" width="20px"></a>';
            $response['pdf'] = '<a id="' . $num . '" onclick="FunCoti(this,2,999,999)"  href="#"><img src="../../img/documents.png" title="Imprimir PDF" alt="" srcset="" width="20px"></a>';
            $response['delete'] = '<a id="' . $num . '" onclick="FunCoti(this,3,999,999)"  href="#"><img src="../../img/eliminar.png" title="Eliminar" alt="" srcset="" width="20px"></a>';
            array_push($dat, $response);



            $cont = 0;
        } else {
            unlink($ruta . "/" . $num . ".json");
        }





    }

    function full_copy($source, $target)
    {
        if (is_dir($source)) {
            @mkdir($target);
            $d = dir($source);
            while (FALSE !== ($entry = $d->read())) {
                if ($entry == '.' || $entry == '..') {
                    continue;
                }
                $Entry = $source . '/' . $entry;
                if (is_dir($Entry)) {
                    full_copy($Entry, $target . '/' . $entry);
                    continue;
                }
                copy($Entry, $target . '/' . $entry);
            }

            $d->close();
        } else {
            copy($source, $target);
        }
    }


    // $source = '../../Cotizaciones/';
    // $destination = '../../duvan/';
    // full_copy($source, $destination);



    header('Content-Type: application/json');

    echo json_encode(array("data" => $dat));



    // return ($option);


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
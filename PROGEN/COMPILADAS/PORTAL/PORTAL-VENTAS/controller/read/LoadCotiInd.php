<?php
error_reporting(0);
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{

    if (isset($_POST['id'])) {
        $cotizacion = $_POST['id'];
        $_SESSION['NumCot']=$_POST['id'];

    }
    if (isset($_POST['tipo'])) {
        $tipo = $_POST['tipo'];

    }

    if (isset($_POST['obs'])) {
        $obs = $_POST['obs'];

    }else{
        $obs='';
    }

    if (isset($_POST['Dir'])) {
        $dir = $_POST['Dir'];

    }else{
        $dir='';
    }

    if (isset($_POST['date'])) {
        $_SESSION['DateCoti'] = $_POST['date'];

    }else{
        unset($_SESSION['DateCoti']);
    }


    $Cliente = trim($_SESSION['Cliente']);
    $tienda = $_SESSION['Loja'];

    $name = $cotizacion . '.json';
    $ruta = '../../Cotizaciones/' . $Cliente . "/" . $tienda;

    $_SESSION["Carrito"] = null;
    $_SESSION['CodCarr'] = $Cliente;
    $_SESSION["info"]=null;

    if ($tipo == 1 || $tipo ==2) {
        $_SESSION["CotizInd"] = (leerJson($ruta, $name));
    }
    if ($tipo == 3) {
        echo DeleteJson($ruta, $name);
    }



    return $tipo."??".$_SESSION["info"]."??".$obs."??".$dir."??".$_SESSION['DateCoti']."??".$cotizacion;

}
;

function leerJson($ruta, $name)
{

    if (file_exists($ruta. "/" . $name)) {
        $Cotizacion = file_get_contents($ruta . "/" . $name);
        $Cotizacion = json_decode($Cotizacion, true);

    } else {
        $Cotizacion = '9999';
        $_SESSION["info"] = $Cotizacion;
    }
    return $Cotizacion;
}
function DeleteJson($ruta, $name)
{

    if (file_exists($ruta. "/" . $name)) {


        unlink($ruta. "/" . $name);
       

    }

}
echo consulta();
?>
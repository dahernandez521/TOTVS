<?php
include "../../model/WebService/rest_services.php";

// unset($_SESSION['detalle']);
// $_SESSION['detalle']=$_SESSION['detail'];


$concat = "nulo";


if (isset($_SESSION['detalle'])) {
    $concat = $_SESSION['detalle'];
    $url = $_maite . '?cod=' . $concat;
} else {

    $url = $_maite;
}

//$url=$_login;

// $sucursal=$_SESSION["FILIAL"];
// $empresa=$_SESSION["EMPRESA"];
// $userportal=$_SESSION['USERPORTAL'];
// $password=$_SESSION['PASSWORD'];
/*
$userportal="AXEL.DIAZ@TOTVS.COM";
$password="12345";
$sucursal="01";
$empresa="01";
*/
$errores = ' ';
// $data_array = http_build_query( array(
//     "USR"       => $userportal,
//     "PWD"       => $password));

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url /*."?".$data_array*/);
curl_setopt($ch, CURLOPT_POST, 0); // set post data to true
//curl_setopt($ch, CURLOPT_POSTFIELDS, $data_array);
//curl_setopt($ch, CURLOPT_HTTPHEADER, array('tenantId: ' . $empresa,$sucursal));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$json = curl_exec($ch);
curl_close($ch);

$obj = json_decode($json, TRUE);
$arreglo = array();
$arreglo = stdToArray($obj);

$_SESSION["json"] = $json;

$_SESSION["productos"] = $obj["product"];

if (!isset($_SESSION['RCruz'])) {
    $url = $_RCruza;
    $errores = ' ';


    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $json = curl_exec($ch);
    curl_close($ch);
    $obj = json_decode($json, TRUE);


    if (isset($obj['RefCruzada'])) {
        $_SESSION['RCruz']=$obj['RefCruzada'];
    }
}else{
    print_r($_SESSION['RCruz']);
}





?>
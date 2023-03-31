<?php
include "model/WebService/rest_services.php";
$url=$_empresa;
//$url   ="http://190.60.28.46:8095/rest/api/framework/environment/v1/branches";
$errores=' ';
$filiales=' ';
$processed = FALSE;
$ERROR_MESSAGE = '';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, 0);// set post data to true
curl_setopt($ch, CURLOPT_HTTPHEADER, array('tenantId: ' . "99","01"));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$json = curl_exec($ch);
curl_close ($ch);

$obj = json_decode($json);

$arreglo=array();
$arreglo=stdToArray($obj);

//$arreglo=stdToArray($arreglo["items"]);

//$_SESSION["filiales"]=stdToArray($arreglo["items"]);
//$_SESSION["arreglo"]=$arreglo;
$filiales=stdToArray($arreglo["items"]);

//print_r($filiales);


$url=$_sucursal;
$errores=' ';
$sucursales=' ';
$processed = FALSE;
$ERROR_MESSAGE = '';
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url);
curl_setopt($ch, CURLOPT_POST, 0);// set post data to true
curl_setopt($ch, CURLOPT_HTTPHEADER, array('tenantId: ' . "99","01"));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$json = curl_exec($ch);
curl_close ($ch);

$obj = json_decode($json);

$arreglo=array();
$arreglo=stdToArray($obj);
if(isset($arreglo["items"])){
    $sucursales=stdToArray($arreglo["items"]);
}


?>

<?php
include "../../model/WebService/rest_services.php";
$url=$_login;

$sucursal=$_SESSION["FILIAL"];
$empresa=$_SESSION["EMPRESA"];
//$userportal=strtoupper($_SESSION['USERPORTAL']);
$userportal=$_SESSION['USERPORTAL'];
$password=$_SESSION['PASSWORD'];





/*
$userportal="AXEL.DIAZ@TOTVS.COM";
$password="12345";
$sucursal="01";
$empresa="01";
*/
$errores=' ';
$data_array = http_build_query( array(
    "USR"       => $userportal,
    "PWD"       => $password));

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url /*."?".$data_array*/);
curl_setopt($ch, CURLOPT_POST, 0);// set post data to true
curl_setopt($ch, CURLOPT_POSTFIELDS, $data_array);
curl_setopt($ch, CURLOPT_HTTPHEADER, array('tenantId: ' . $empresa,$sucursal));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$json = curl_exec($ch);
curl_close ($ch);

$obj = json_decode($json,true);
$arreglo=array();
$arreglo=stdToArray($obj);
if(isset($arreglo["UserData"][0])){
$_SESSION["login"]=stdToArray($arreglo["UserData"][0]);
}
// $_SESSION["login"]=$obj["UserData"];




?>


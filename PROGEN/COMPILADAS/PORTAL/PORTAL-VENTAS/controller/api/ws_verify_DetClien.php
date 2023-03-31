<?php
include "../../model/WebService/rest_services.php";

// unset($_SESSION['detalle']);
// $_SESSION['detalle']=$_SESSION['detail'];

 
if(isset($_SESSION['Cliente'])){
$url=$_DetClien."?cod=".$_SESSION['Cliente'];


// echo $url;



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
$errores=' ';
// $data_array = http_build_query( array(
//     "USR"       => $userportal,
//     "PWD"       => $password));

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $url /*."?".$data_array*/);
curl_setopt($ch, CURLOPT_POST, 0);// set post data to true
//curl_setopt($ch, CURLOPT_POSTFIELDS, $data_array);
//curl_setopt($ch, CURLOPT_HTTPHEADER, array('tenantId: ' . $empresa,$sucursal));
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$json = curl_exec($ch);
curl_close ($ch);

$obj = json_decode($json,TRUE);
$arreglo=array();
$arreglo=stdToArray($obj);

// if (isset($arreglo["ClientxU"])){

//     $L_preci=stdToArray($arreglo["ClientxU"][0]);
// }

// if(isset($L_preci['pricelist'])){
//     $_SESSION["L_preci"]=$L_preci['pricelist'];
// }else{
//     $_SESSION["L_preci"]=0;
// }

// echo "<script> DeleteMaestroProduct() </script>";

if (isset($obj['ClientxU'])){
    $_SESSION["clientes"]=$obj['ClientxU'];
    // print_r($_SESSION["clientes"]);

}

// print_r(count($obj['clients']));
// $_SESSION["clientes"]=$obj["product"];

}

?>


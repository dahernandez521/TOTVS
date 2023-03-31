<?php
include "../../model/WebService/rest_services.php";
if (session_status() == PHP_SESSION_NONE) {
    session_start();
  }

$url=$_Fpago;
$errores=' ';


$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$json = curl_exec($ch);
curl_close($ch);
$obj = json_decode($json,TRUE);

if (isset($obj['CondPago'])){
    $_SESSION['Fpago']=$obj['CondPago'];
    // echo $json;
}




?>
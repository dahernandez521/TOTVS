<?php

include "../../model/WebService/rest_services.php";

if (isset($_SESSION['DetPed'])) {
 
  $url=$_DetPed."?cod=".$_SESSION['DetPed'];

  $ch = curl_init($url);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  $response = curl_exec($ch);
  curl_close($ch);
  $obj = json_decode($response, TRUE);
  $arreglo=array();
  $arreglo=stdToArray($obj);

  if (isset($obj['PedVenDet'])) {
     $_SESSION["DetallePedido"] = $obj['PedVenDet'];
    
  }

} 
?>
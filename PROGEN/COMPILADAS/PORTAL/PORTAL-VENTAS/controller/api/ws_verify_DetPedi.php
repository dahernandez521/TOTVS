<?php

include "../../model/WebService/rest_services.php";

if (isset($_SESSION['DetPed'])) {
  $url = $_ConPed . "?cod=" . $_SESSION['DetPed'] . "";


  $url = $url . "&DIni=" . str_replace("-", "", $_SESSION["FecInic"]) . "&DFin=" . str_replace("-", "", $_SESSION["FecFini"]);


  $_SESSION['UrlDetPedi']=$url;
  $ch = curl_init($url);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  $response = curl_exec($ch);
  curl_close($ch);
  $obj = json_decode($response, TRUE);
  $arreglo=array();
  $arreglo=stdToArray($obj);


  if (isset($obj['PedVeEnc'])) {
    $_SESSION["DetPedido"] =stdToArray($arreglo['PedVeEnc'][0]);
    // $_SESSION["DetPedido"] = $obj['PedVeEnc'];
    
  }
  // print_r($url);


  
} 
?>
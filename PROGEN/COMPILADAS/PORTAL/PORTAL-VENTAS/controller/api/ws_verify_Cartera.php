<?php

include "../../model/WebService/rest_services.php";

if (isset($_SESSION['Cliente'])) {
  unset($_SESSION["Cartera"]);
  $Comodin= "&DIni=" . str_replace("-", "", $_SESSION["FecInic"]) . "&DFin=" . str_replace("-", "", $_SESSION["FecFini"])."&Cloja=".$_SESSION["Loja"];

  $url = $_Carte . "?COD=" . trim($_SESSION['Cliente'])  . $Comodin;
  $_SESSION['UrlCartera']=$url;

  $chi = curl_init($url);
  curl_setopt($chi, CURLOPT_RETURNTRANSFER, true);
  $respons = curl_exec($chi);
  curl_close($chi);
  $obje = json_decode($respons, TRUE);


  if (isset($obje['Cartera'])) {
    $_SESSION["Cartera"] = $obje['Cartera'];

  }
  //  print_r($url);



}
?>
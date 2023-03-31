<?php

include "../../model/WebService/rest_services.php";

if (isset($_SESSION["Mail"])) {

  $url = $_Email . "?COD=" . trim($_SESSION["Mail"])  ;


  $chi = curl_init($url);
  curl_setopt($chi, CURLOPT_RETURNTRANSFER, true);
  $respons = curl_exec($chi);
  curl_close($chi);
  $obje = json_decode($respons, TRUE);


  if (isset($obje['ValMail'])) {
    $_SESSION["ValMail"] = $obje['ValMail'];

  }
    // print_r($url);



}
?>
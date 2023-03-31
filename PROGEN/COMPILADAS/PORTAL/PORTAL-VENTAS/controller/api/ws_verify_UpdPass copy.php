<?php

include "../../model/WebService/rest_services.php";

unset($_SESSION["RecMail"]);
$param = "&Mail=" . trim($_SESSION["maiPor"]) . "&Pass=" . trim($_SESSION["pasPor"]);


  $url = $_UpPas . "?COD=" . trim($_SESSION["usuPor"]).$param  ;


  $chi = curl_init($url);
  curl_setopt($chi, CURLOPT_RETURNTRANSFER, true);
  $respons = curl_exec($chi);
  curl_close($chi);
  $obje = json_decode($respons, TRUE);


  if (isset($obje['RecMail'])) {
    $_SESSION["RecMail"] = $obje['RecMail'];

  }
    // print_r($url);




?>
<?php
if (session_status() == PHP_SESSION_NONE) {
  session_start();
}

if (!isset($_SESSION["ImpIVA"]) || count($_SESSION["ImpIVA"])<1) {
  include "../../model/WebService/rest_services.php";

  $url = $_Impues;

  $ch = curl_init($url);
  curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
  $response = curl_exec($ch);
  $res = str_replace("?", "", utf8_decode($response));
  curl_close($ch);
  $obj = json_decode($response, TRUE);


  if (isset($obj['IvaProd'])) {
    $_SESSION["ImpIVA"] = $obj['IvaProd'];
  }

  print_r($response);



}else{
  print_r( $_SESSION["ImpIVA"]);
}
?>
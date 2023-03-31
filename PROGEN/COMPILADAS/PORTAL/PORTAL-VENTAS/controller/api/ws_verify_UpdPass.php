<?php
if (session_status() == PHP_SESSION_NONE) {
  session_start();
}
include "../../model/WebService/rest_services.php";

unset($_SESSION["RecMail"]);

if (isset($_POST['Pass'] )){
  $_SESSION["maiPor"]=$_SESSION['MaiUser'];
  $_SESSION["usuPor"] = $_SESSION['CodUser'];
  $_SESSION["pasPor"] = $_POST['Pass'];
}

$param = "&Mail=" . trim($_SESSION["maiPor"]) . "&Pass=" . trim($_SESSION["pasPor"]);


  $url = $_UpPas . "?COD=" . trim($_SESSION["usuPor"]).$param  ;

  $_SESSION['UrlCamPass']=$url;

  $chi = curl_init($url);
  curl_setopt($chi, CURLOPT_RETURNTRANSFER, true);
  $respons = curl_exec($chi);
  curl_close($chi);
  $obje = json_decode($respons, TRUE);


  if (isset($obje['RecMail'])) {
    $_SESSION["RecMail"] = $obje['RecMail'];

  }


  if (isset($_POST['Pass'] ) && isset($_SESSION["RecMail"])){
    print_r(1);
    // print_r($url);
  }
    // print_r($url);




?>
<?php

if (!isset($_SESSION["DetRegla"])) {
  include "../../model/WebService/rest_services.php";


  if (session_status() == PHP_SESSION_NONE) {
    session_start();
  }

  if (isset($_SESSION['Cliente'])) {

    if (isset($_SESSION["ClienteFina"])) {

      $Cliente = $_SESSION["ClienteFina"];
      unset($_SESSION["ClienteFina"]);

    } else {

      $Cliente = $_SESSION['Cliente'];
    }




    // $url=$_Rnego."?cod=".$Cliente;

    $url = $_Rnego;

    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $response = curl_exec($ch);
    curl_close($ch);
    $obj = json_decode($response, TRUE);


    if (isset($obj['RegDtoDet'])) {
      $_SESSION["DetRegla"] = $obj['RegDtoDet'];

       print_r($response);
    } else {
      unset($_SESSION["DetRegla"]);
    }
    // print_r($url);




  }
}
?>
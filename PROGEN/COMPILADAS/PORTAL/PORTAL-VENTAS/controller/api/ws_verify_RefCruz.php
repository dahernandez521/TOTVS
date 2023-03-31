<?php

if (session_status() == PHP_SESSION_NONE) {
    session_start();
  }
if ((!isset($_SESSION['RCruz'])) || (count($_SESSION['RCruz']))<1) {
    include "../../model/WebService/rest_services.php";


    $url = $_RCruza;
    $errores = ' ';


    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $json = curl_exec($ch);
    curl_close($ch);
    $obj = json_decode($json, TRUE);
    $_SESSION['objRCruz'] = $json;

    if (isset($obj['RefCruzada'])) {
        $_SESSION['RCruz'] = $obj['RefCruzada'];
       
    }
    // print_r($json);


}
else{
    // echo $_SESSION['objRCruz'];
}



?>
<?php
if (!isset($_SESSION["clientes"])) {
    include "../../model/WebService/rest_services.php";

    // unset($_SESSION['detalle']);
// $_SESSION['detalle']=$_SESSION['detail'];


    if (isset($_SESSION['CodVen'])) {
        $url = $_clienVend . "?cod=" . trim($_SESSION['CodVen']);
    } else if (isset($_SESSION['CodUsu'])) {
        $url = $_clienUsua . "?cod=" . trim($_SESSION['CodUsu']);
    }


    if (isset($url)) {

        $_SESSION["urlc"] = $url;

        $errores = ' ';


        $ch = curl_init($url);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $json = curl_exec($ch);
        curl_close($ch);
        $obj = json_decode($json, TRUE);


        if (isset($obj['ClientxU'])) {
            $_SESSION['CacheClien'] = $json;
            $_SESSION["clientes"] = $obj['ClientxU'];
            // $_SESSION["clientes"]=$obj['ClientxU'];
        }


    }
}

?>
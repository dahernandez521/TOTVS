<?php
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}
if (isset($_SESSION["L_preci"])) {
    include "../../model/WebService/rest_services.php";
    date_default_timezone_set("America/Bogota");

    $concat = "nulo";

    $concat = $_SESSION["L_preci"];
     $url = $_Lpreci . '?cod=' . $concat;
    // $url = $_Lpreci;

    $_SESSION['UrlProductos']=$url;

    $errores = ' ';
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url /*."?".$data_array*/);
    curl_setopt($ch, CURLOPT_POST, 0); // set post data to true
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    $json = curl_exec($ch);
    curl_close($ch);

    $obj = json_decode($json, TRUE);
    // $arreglo = array();
    // $arreglo = stdToArray($obj);

    $_SESSION["json"] = $json;
    $_SESSION["UltConsProd"] = date("d-m-Y h:i:s");

    // print_r("JSON: ".$obj["LisPreDet"]);

    if (isset($obj["LisPreDet"])) {
        $_SESSION["productos"] = $obj["LisPreDet"];       
    }

}
// print_r ($_SESSION["productos"]);




?>
<?php
include "../../model/WebService/rest_services.php";


$url=$_Depart;
$errores=' ';


$ch = curl_init($url);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$json = curl_exec($ch);
curl_close($ch);
$obj = json_decode($json,TRUE);


if (isset($obj['Municipios'])){
    echo $json;
}




?>
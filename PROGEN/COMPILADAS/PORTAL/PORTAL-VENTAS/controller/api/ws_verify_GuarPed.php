<?php
include "../../model/WebService/rest_services.php";
if (session_status() == PHP_SESSION_NONE) {
    session_start();
  }
  
if (isset($_POST['CrePedVent'])) {
    $array = $_POST['CrePedVent'];

    $_SESSION['CrePedVent'] =$_POST['CrePedVent'];
    // $url = $_CrePed.$array;
    $url = $_CrePed;
    $_SESSION['URL'] =$url;



    if (isset($url)) {

        $data_array =$_POST['CrePedVent'];

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $url /*."?".$data_array*/);
        curl_setopt($ch, CURLOPT_POST, 1);// set post data to true
        curl_setopt($ch, CURLOPT_POSTFIELDS, $data_array);
        curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json'));
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        $json = curl_exec($ch);
        curl_close ($ch);

        // $obj = json_decode($json, TRUE);


        // if (isset($obj['ClientxU'])) {
        //     $_SESSION["clientes"] = $obj['ClientxU'];
        //     // print_r($_SESSION["clientes"]);

        // }

        print_r(utf8_decode($json));

    }
}
?>
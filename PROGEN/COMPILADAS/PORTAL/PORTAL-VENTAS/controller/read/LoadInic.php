<?php

if (session_status() == PHP_SESSION_NONE) {
    session_start();
}
function consulta()
{

   
    include '../../controller/api/ws_verify_produ.php';
    $_SESSION["json"];
    include '../../controller/api/ws_verify_RefCruz.php';
    
    include '../../controller/api/ws_verify_Modalidad.php';
    $option=$_SESSION['CacheModali'];

    include '../../controller/api/ws_verify_Depart.php';
    include '../../controller/api/ws_verify_Munici.php';
    include '../../controller/api/ws_verify_FoPago.php';
    include '../../controller/api/ws_verify_ReNego.php';
    include '../../controller/api/ws_verify_ImpIVA.php';
    
    
    
    
  
    return ($_SESSION["json"]);


}
;

echo consulta();
?>
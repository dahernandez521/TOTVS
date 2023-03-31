<?php
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}
function consulta()
{

     unset($_SESSION['RCruz']);
     unset($_SESSION['ImpProd']);
     unset($_SESSION['ModProd']);
     unset($_SESSION["json"]);
   

   


     include '../../controller/api/ws_verify_produ.php';
     include '../../controller/api/ws_verify_RefCruz.php';


    // $obj = json_decode($_SESSION["json"], TRUE);

    // $_SESSION["productos_obj"] = $obj["LisPreDet"];
 
    return ( $_SESSION["json"]. "??" . $_SESSION['objRCruz']);


}
;

echo consulta();
?>
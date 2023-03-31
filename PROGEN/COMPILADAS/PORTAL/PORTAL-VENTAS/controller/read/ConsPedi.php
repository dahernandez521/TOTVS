<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{
    if (isset($_POST['FecInic'])) {
        $_SESSION["FecInic"] = $_POST['FecInic'];
        $_SESSION["FecFini"] = $_POST['FecFini'];
    }

    include '../../controller/api/ws_verify_pedi.php';


    include 'TablaPedidos.php'; 


    


    return ($option);


}
;

echo consulta();
?>
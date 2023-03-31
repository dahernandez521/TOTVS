<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{
    if (isset($_POST['FecInic'])) {
        $_SESSION["FecInic"] = $_POST['FecInic'];
        $_SESSION["FecFini"] = $_POST['FecFini'];
    }

    //  include '../../controller/api/ws_verify_pedi.php';

    include '../../controller/api/ws_verify_Cartera.php';


    include 'TablaCartera.php'; 



    $_SESSION['DeCart'] = $option;
    $_SESSION['Total'] = $Total;
    $_SESSION['Modal'] = $MC;


    $tabla=$cabeza.$option.$fotter.$Total.$MC;


    return ($tabla);


}
;

echo consulta();
?>
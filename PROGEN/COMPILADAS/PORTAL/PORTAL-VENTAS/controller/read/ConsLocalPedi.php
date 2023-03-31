<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{

    if (isset($_POST['array'])) {
        $array = $_POST['array'];
        // $_SESSION['productos_obj']=$array["LisPreDet"];
        $obje = json_decode($array, TRUE);
        $_SESSION["Pedidos"] = $obje['PedVeEnc'];

    }


    include 'TablaPedidos.php'; 


    return ($option);


}
;

echo consulta();
?>
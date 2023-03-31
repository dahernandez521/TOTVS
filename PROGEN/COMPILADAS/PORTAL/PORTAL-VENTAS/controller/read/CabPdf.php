<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{
    if (isset($_POST['Obs'])){
        $obs = $_POST['Obs'];
    }else{
        $obs='Pedido sin Observación';
    }
    
    if (isset($_POST['Dir'])){
        $dir = $_POST['Dir'];
    }else{
        $dir='Pedido sin Direccion de Entrega';
    }


    $_SESSION['Obs'] = $obs;
    $_SESSION['Dir'] = $dir;




}
;

echo consulta();
?>
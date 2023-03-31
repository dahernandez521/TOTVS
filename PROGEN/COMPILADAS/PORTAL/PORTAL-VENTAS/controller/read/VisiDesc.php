<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{   
    $usuario=null;
    if(isset($_SESSION['CodVen'])){
        $usuario=2;
    }else if(isset($_SESSION['CodUsu'])){
        $usuario=1;
    }

// se deja quemado para que todos los suuariosvean los campos de descuento
    $usuario = 2;


    return ($usuario);


}
;

echo consulta();
?>
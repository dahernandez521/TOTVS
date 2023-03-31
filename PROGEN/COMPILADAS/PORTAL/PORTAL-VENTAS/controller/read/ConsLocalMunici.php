<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{


    if (isset($_POST['Munici'])) {
        $array = $_POST['Munici'];
        $obje = json_decode($array, TRUE);
        $_SESSION["Municipios"] = $obje['Municipios'];        
        $_SESSION['code']=$_SESSION['Municipio'];

    }

    $option = "<option id='0' value='0' >SELECCIONE LA CIUDAD</option>";

    foreach ($_SESSION["Municipios"] as $row) {

        include 'TablaDiviPol.php'; 

    }

    return ($option);


}
;

echo consulta();
?>
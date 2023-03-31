<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{

    if (isset($_POST['Depart'])) {
        $array = $_POST['Depart'];
        $obje = json_decode($array, TRUE);
        $_SESSION["Departamentos"] = $obje['Municipios'];
        $_SESSION['code']=$_SESSION['Departamento'];
    }




$option = "<option id='0' value='0' >SELECCIONE DEPARTAMENTO</option>";

    foreach ($_SESSION["Departamentos"] as $row) {

        include 'TablaDiviPol.php'; 

    }

    return ($option);


}
;

echo consulta();
?>
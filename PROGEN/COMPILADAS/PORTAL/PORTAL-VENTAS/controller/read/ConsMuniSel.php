<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{


    if (isset($_POST['Departamento'])) {
        $Depart = $_POST['Departamento'];

    }

    $option = "<option id='0' value='0' >SELECCIONE LA CIUDAD</option>";

    foreach ($_SESSION["Municipios"] as $row) {

        if ($Depart == $row['dep']) {

            $option .= "<option id=" . $row['code'] . " value='$row[code]' >" . $row['descsri'] . " - " . $row['code'] . "</option>";
        } 

    }

    return ($option);


}
;

echo consulta();
?>
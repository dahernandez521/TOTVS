<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{
 
   
    $option = null;

    if(isset($_SESSION['clientes'])){
        foreach ($_SESSION['clientes'] as $row ) {
            $option .= "<option id=".trim($row['code'])." value='".trim($row['code'])."'>$row[namefan]</option>";
        }

    }

echo ($option);

    
}
;

echo consulta();
?>
<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{       
        
    if(!isset($_SESSION["CachePedi"])){
        $_SESSION["CachePedi"]=null;
    }
    
 return ($_SESSION["CachePedi"]);

    
}
;

echo consulta();
?>
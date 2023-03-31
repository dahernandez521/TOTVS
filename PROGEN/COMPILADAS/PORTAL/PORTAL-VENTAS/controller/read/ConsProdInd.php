<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{

    $produc = trim($_POST['Produc']);

    $option = null;
    $contador = 1;
    $tes = 123;


    foreach ($_SESSION["productos_obj"] as $key => $Detalle) {


        if ($_SESSION["L_preci"] === $Detalle["code_lp"]) {


            

            if (isset($_SESSION['RCruz'])) {
                foreach ($_SESSION['RCruz'] as $ref) {
                    if (trim($ref['cliente'] === trim($_SESSION['Cliente']))) {
                        if (trim($ref['codecli']) === $produc) {
                            $produc = $ref['codepro'];
                            $tes = $Detalle['tes'];
                            $contador = 0;
                            break;
                        }
                    }
                }
            }

            if ($Detalle['code'] === $produc && $contador==1) {
                $tes = $Detalle['tes'];
                break;
                
            }

            
            


        }
        
    }
return ($tes.'??'.$_POST['vd']);




};

echo consulta();
?>
<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{

    $option = null;

    if (!isset($_SESSION['Fpago'])) {

        include '../../controller/api/ws_verify_FoPago.php';
    }



    if (isset($_SESSION['Fpago'])) {
        if (isset($_SESSION['clientes'])) {
            if (isset($_SESSION['Cliente'])) {
                foreach ($_SESSION['clientes'] as $key => $Clien) {
                    if (trim($Clien['code']) == trim($_SESSION['Cliente'])) {
                        if ($Clien['store'] === $_SESSION['Loja']) {
                            $Fpago = $Clien['paymentterms'];
                            break;
                        }
                    }
                }
                include 'FormasPago.php';
            }else{
                $option = 1;
            }
        }else{
            $option = 1;
        }
    }else{
        $option = 1;
    }


    return ($option);
}
;

echo consulta();
?>
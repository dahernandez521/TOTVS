<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{

    if (isset($_SESSION['Cliente'])) {

        $Modi=null;
        if(isset($_SESSION['CodVen'])){
            $Modi="2";
            
            $user=$_SESSION["login"]['LOGIN'];
        }else if(isset($_SESSION['CodUsu'])){
            $Modi="1";
            $user=$_SESSION["login"]['LOGIN'];
        }



        foreach ($_SESSION['clientes'] as $key => $Detalle) {
            if ($Detalle['code'] === $_SESSION['Cliente']) {
                if ($Detalle['store'] === $_SESSION['Loja']) {
                    $datos =
                        $Detalle['code'] . //Client   0      
                        "??" . $Detalle['store'] . //Store  1
                        "??" . $Detalle['code'] . //Cliente 2
                        "??" . $Detalle['store'] . //DeliveryStore  3
                        "??" . $Detalle['paymentterms'] . //PaymentTerms    4
                        //"MessageForNote": "Mensagem para nota",
                        "??" . "CLIENTES" . //Nature   5
                        //"DireccionEnt": "CR 78 CC 45 10",
                        "??" . $Detalle['depdirentre'] . //DepartamentonEnt   6
                        "??" . $Detalle['mundirentre'] . //MunicipioEnt   7
                        "??" . $Detalle['descuent'] . //Descuento 8
                        "??" . $Modi . //permite modificar 9
                        "??" . $user; //usuario 10

                    break;
                }
            }
        }

    } else {
        $datos =
            "000000000" . //Client         
            "??" . "0" . //Store
            "000000000" . //Cliente 
            "??" . "0" . //CustomerDelivery
            "??" . "0" . //DeliveryStore
            "??" . "0" . //PaymentTerms
            "??" . "0". //Nature
            "??" . "0". //Descuento
            "??" . "1"; //permite modificar
            "??" . ""; //usuario

    }
    return ($datos);


}
;

echo consulta();
?>
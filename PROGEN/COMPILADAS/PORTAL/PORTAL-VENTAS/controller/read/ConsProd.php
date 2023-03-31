<?php
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}
function consulta()
{
    
    if (isset($_POST['Cliente'])) {
        $_SESSION["L_preci"] = $_POST['Lpreci'];
        $_SESSION["Cliente"] = $_POST['Cliente'];
        $_SESSION["Loja"] = $_POST['Loja'];
        $_SESSION["ClienteFina"] = $_POST['Cliente'];


        if (isset($_SESSION["L_preci_ANT"])) {

            if ($_SESSION["L_preci_ANT"] <> $_SESSION["L_preci"]) {
                unset($_SESSION["json"]);
            }

        }
        $_SESSION["L_preci_ANT"] = $_POST['Lpreci'];
    }


    if ((!isset($_SESSION["json"])) || (($_SESSION["json"]) == '0')) {
        include '../../controller/api/ws_verify_produ.php';

        include '../../controller/api/ws_verify_RefCruz.php';


    }

    if (!isset($_SESSION['CacheModali'])) {
        include '../../controller/api/ws_verify_Modalidad.php';
    }


    if (!isset($_SESSION["json"])) {
        $_SESSION["json"] = 0;
    }



    if(isset($_SESSION['CodVen'])){
        $Modi="2";       
        $user=$_SESSION["login"]['LOGIN'];
    }else if(isset($_SESSION['CodUsu'])){
        $Modi="1";
        $user=$_SESSION["login"]['LOGIN'];
    }

    $datos = 0;
    if (isset($_SESSION['Cliente'])) {

        foreach ($_SESSION['clientes'] as $key => $Detalle) {
            if ($Detalle['code'] === $_SESSION['Cliente']) {

                if($Detalle['store']===$_SESSION['Loja']){


                $datos =
                    $Detalle['code'] . //Client   0      
                    "¿?" . $Detalle['store'] . //Store  1
                    "¿?" . $Detalle['code'] . //Cliente 2
                    "¿?" . $Detalle['store'] . //DeliveryStore  3
                    "¿?" . $Detalle['paymentterms'] . //PaymentTerms    4
                    //"MessageForNote": "Mensagem para nota",
                    "¿?" . "CLIENTES" . //Nature   5
                    //"DireccionEnt": "CR 78 CC 45 10",
                    "¿?" . $Detalle['depdirentre'] . //DepartamentonEnt   6
                    "¿?" . $Detalle['mundirentre'] . //MunicipioEnt   7
                    "¿?" . $Detalle['descuent'] . //Descuento 8
                    "¿?" . $Modi . //permite modificar 9
                    "¿?" . $user; //usuario 10

                break;
            }
            }
        }

    }






    // $option = '<option >Seleccione</option>';

    // if(isset($_SESSION["productos"])){
    //     foreach ($_SESSION["productos"] as $row ) {
    //         $option .= "<option value='$row[code]'>$row[name]</option>";
    //     }
    // }
    return ($_SESSION["json"] . "??" . $_SESSION['objRCruz'] . "??" . $_SESSION['CacheModali']."??".$_SESSION["L_preci"]."??".$datos);


}
;

echo consulta();
?>
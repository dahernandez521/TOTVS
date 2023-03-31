<?php
require_once("../../controller/verification/functions.php");
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

/**
 *
 * Valida un email usando funciones de manejo de strings. 
 *  Devuelve true si es correcto o false en caso contrario
 *
 * @param    string  $str la dirección a validar
 * @return   boolean
 *
 */
function validationEmail($str)
{
    return (false !== strpos($str, "@") && (false !== strpos($str, ".") && false !== strpos($str, ".com") && false !== strpos($str, ".co")));
}


function consulta()
{
    $val = 0;
    if (isset($_POST['Mail'])) {
        $_SESSION["Mail"] = $_POST['Mail'];
        $val = validationEmail($_POST['Mail']);
    }




    if ($val == 1) {
        include '../../controller/api/ws_verify_Mail.php';
    }

    if (isset($_SESSION["ValMail"])) {

        foreach ($_SESSION["ValMail"] as $row) {
            $usuario = $row['NOME'];
            $user = strtolower($row['EMAIL']);
            break;
        }

        if (isset($user) && strlen(trim($user)) > 1) {



            include '../../controller/update/CamPass.php';
        }else{
            $val = 0;
        }

    }else{
        $val = 0;
    }
    // include '../../controller/api/ws_verify_produ.php';

    unset($_SESSION["Mail"]);
    unset($_SESSION["ValMail"]);

    return ("??" . $val . "??" . '');


}
;

echo consulta();
?>
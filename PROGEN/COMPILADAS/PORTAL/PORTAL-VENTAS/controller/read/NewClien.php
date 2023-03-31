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
    }






    // $option = '<option >Seleccione</option>';

    // if(isset($_SESSION["productos"])){
    //     foreach ($_SESSION["productos"] as $row ) {
    //         $option .= "<option value='$row[code]'>$row[name]</option>";
    //     }
    // }
    // return ($_SESSION["Cliente"]);


}
;

echo consulta();
?>
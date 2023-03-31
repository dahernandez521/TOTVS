<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{   
    if(isset($_POST['refresh'])){
        unset($_SESSION['option']);
    }

    if (!isset($_SESSION['option']) || strlen(trim($_SESSION['option']))<5) {
        if (isset($_POST['array'])) {
            $array = $_POST['array'];
            // $_SESSION['productos_obj']=$array["LisPreDet"];
            $obj = json_decode($array, TRUE);
            if (isset($obj["LisPreDet"])) {
                $_SESSION["productos_obj"] = $obj["LisPreDet"];
            } else {
                include '../../controller/api/ws_verify_produ.php';
                $_SESSION["productos_obj"] = $_SESSION["productos"];
            }


        }




        $option = null;

        if (isset($_SESSION["productos_obj"])) {
            foreach ($_SESSION["productos_obj"] as $row) {

                if ($_SESSION["L_preci"] === $row["code_lp"]) {


                    $RefCruz = trim($row['code']);
                    $Cruz = 1;


                    if (isset($_SESSION['RCruz'])) {
                        foreach ($_SESSION['RCruz'] as $ref) {
                            if (trim($ref['cliente'] === trim($_SESSION['Cliente']))) {
                                if (trim($ref['codepro']) === trim($row["code"])) {
                                    if (trim($ref['codecli']) != "") {
                                        $option .= "<option id=" . (str_replace("/", "-", (str_replace(".", "", substr($ref['codecli'], 0, 25))))) . "-" . " value=" . trim($ref['codecli']) . ">" . str_replace('"', "", $ref['descripcli']) . "</option>";

                                        $Cruz = 0;
                                    }
                                    break;
                                }
                            }
                        }
                    }

                     $option .= "<option id=" . (str_replace("/", "-", (str_replace(".", "", substr($row['code'], 0, 25))))) . "-" . " value=" . trim($RefCruz) . ">" . str_replace('"', "", $row['name']) . "</option>";
                    //  $option .= "<option  id=".trim($row["item"])." value=" .trim($row['item']). " class='LisProdIn'>" . trim($RefCruz).' '.str_replace('"', "", $row['name']) ."</option>";

                }
            }

        }

        $_SESSION['option'] = $option;
        $error=0;

    }else{
        $error=1;
    }

    echo ($_SESSION['option']."??".$error);


}
;

echo consulta();
?>
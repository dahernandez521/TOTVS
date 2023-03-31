<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{
    $option = null;
    if(isset($_POST['array'])){
        $array = $_POST['array'];
        // $_SESSION['productos_obj']=$array["LisPreDet"];
        $obj = json_decode($array,TRUE);
        $_SESSION["Modalidades"]=$obj["Modalidad"];
        $modalidad16 = "0300118"; //modalidad para cleintes antiguos


        if(isset($_SESSION["Modalidades"])){
            foreach ($_SESSION["Modalidades"] as $row ) {

                if (trim($row['habil'] == "1")) {

                    if (trim($row['code']) == "") {
                        $row['code'] = 0;
                    }

                    // modalidad para clientes antiguos   
                    if (
                        trim($_SESSION['Cliente']) == "901019138" ||
                        trim($_SESSION['Cliente']) == "901401130" ||
                        trim($_SESSION['Cliente']) == "901126410"
                    ) {
                        if ($row['code'] == $modalidad16) { //modalidad del 16%
                            $option = "<option value='$row[code]'>" . $row['code'] . " - " . $row['descsri'] . "</option>";
                            break;
                        }
                    }
                    if ($row['code'] != $modalidad16) { //modalidad del 16%
                        if ($_SESSION['Modalidad'] == $row['code']) {
                            $option .= "<option value='$row[code]' selected>" . $row['code'] . " - " . $row['descsri'] . "</option>";
                        }
                        // else {
                        //     $option .= "<option value='$row[code]'>" . $row['code'] . " - " . $row['descsri'] . "</option>";
                        // }
                    }
                }
            }

            
           
    
        }
        
    }else{
        include '../../controller/api/ws_verify_Modalidad.php';

        $option=$_SESSION['CacheModali'];
    }

    

   
    

    

echo ($option);

    
}
;

echo consulta();
?>
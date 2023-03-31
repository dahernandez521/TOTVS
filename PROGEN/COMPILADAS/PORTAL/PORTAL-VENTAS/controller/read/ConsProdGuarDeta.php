<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{
    if (isset($_POST['produc'])) {
        $produc = $_POST['produc'];
        $producRef = $_POST['produc'];
    }
    if (isset($_POST['refec'])) {
        $producRef = $_POST['refec'];
    }


    $option = 0;
    $ValDes = 0.0;
    $imputes = 0.0;
    $nametes = "";
    $porcimp = 0.0;
    $stock_Vis=0;
    $stock=0.0;


    if(isset($_SESSION['CodVen'])){
        $stock_Vis = 1;
    }





    foreach ($_SESSION["productos_obj"] as $key => $Detalle) {
        if ($_SESSION["L_preci"] === $Detalle["code_lp"]) {
            if ($Detalle['code'] === $produc) {
                $option = $Detalle['saleprice'];
                $stock = $Detalle['StockAct'];
                $grupo = $Detalle['grupop'];
                $Lpreci = $Detalle['code_lp'];
                break;
            }
        }
    }


    if (isset($_SESSION["DetRegla"])) {
        foreach ($_SESSION["DetRegla"] as $Reg => $Des) {
            if ($Des['group'] === $Detalle['grupop'] && trim($Des['codecli']) === trim($_SESSION['Cliente']) && trim($Des['discountpercentage']) > 0) {
                $ValDes = $Des['discountpercentage'];
                break;
            }
        }
    }

    if (
        trim($_SESSION['Cliente']) == "901019138" ||
        trim($_SESSION['Cliente']) == "901401130" ||
        trim($_SESSION['Cliente']) == "901126410"
    ) {
        
                    $imputes = "IV6";
                    $nametes = "IVA DEL 16%";
                    $porcimp = 16;
      
    } else {
    
        if (isset($_SESSION["ImpIVA"])) {
            foreach ($_SESSION["ImpIVA"] as $iva => $Imp) {
                if ($Imp['codeprod'] === $produc) {
                    $imputes = $Imp['imputes'];
                    $nametes = $Imp['descrimp'];
                    $porcimp = $Imp['porcimp'];
                    break;
                }
            }
        }
    }





    if ($option < 1) {


        if (isset($_SESSION['RCruz'])) {
            foreach ($_SESSION['RCruz'] as $ref) {
                if (trim($ref['cliente'] === trim($_SESSION['Cliente']))) {
                    if (trim($ref['codecli']) === trim($produc)) {
                        if (trim($ref['codecli']) != "") {
                            $produc = $ref['codepro'];
                            $producRef = $ref['codecli'];
                        }
                        break;
                    }
                }
            }
        }

    }


    return ($option . "??" . $ValDes . "??" . $produc . "??" . $imputes . "??" . $nametes . "??" . $porcimp."??".$producRef."??".$stock."??".$stock_Vis);


}
;

echo consulta();
?>
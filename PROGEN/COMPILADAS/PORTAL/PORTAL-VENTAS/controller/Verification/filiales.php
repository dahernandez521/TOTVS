<?php

function filiales()
{
    if (
        isset($_SESSION["filiales"]) and !empty($_SESSION["filiales"]) and
        isset($_SESSION["sucursales"]) and !empty($_SESSION["sucursales"])
    ) {
        $filiales = $_SESSION["filiales"];
        $sucursales = $_SESSION["sucursales"];
        $_empresa = $_SESSION["WEBWS"];
    }


    
    if (!isset($filiales)) {
        include 'ws_filial01.php';
        $_SESSION["filiales"] = $filiales;
        $_SESSION["sucursales"] = $sucursales;
    } else {
        print_r($filiales);

        if (!(count($filiales) > 0 and count($sucursales) > 0)) {
            include 'ws_filial01.php';
            $_SESSION["filiales"] = $filiales;
            $_SESSION["sucursales"] = $sucursales;
        }
    }


    $value = 1;
    foreach ($filiales as $v1) {
        foreach ($sucursales as $v2) {
            if ($v2["EnterpriseGroup"] == $v1["Code"]) {
                if ($value == 1 and !($v1["Code"] == '99')) {
                    echo "<option selected value='" . $v1["Code"] . "/" . $v2["Code"] . "'>" . $v1["CorporateName"] . "/" . $v2["Title"] . "</option>\n";
                    $value = 2;
                } else {
                    echo "<option value='" . $v1["Code"] . "/" . $v2["Code"] . "'>" . $v1["CorporateName"] . "/" . $v2["Title"] . "</option>\n";
                }
            }
        }
    }



    print_r("saludos progen");


}

?>
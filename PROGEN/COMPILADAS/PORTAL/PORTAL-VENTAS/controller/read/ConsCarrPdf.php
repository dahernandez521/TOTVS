<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{
    if (isset($_POST['Clien'])) {
        $_SESSION['CodCarr'] = $_POST['Clien'];
    }

    if (isset($_POST['array'])) {
        $array = $_POST['array'];
        // $_SESSION['productos_obj']=$array["LisPreDet"];
        $obje = json_decode($array, TRUE);


        $_SESSION["Carrito"] = $obje;
    }

    if (isset($_SESSION['CodCarr'])) {

        $option = null;
        $contador = 1;
        $ProdFin = "";
        $produc =  "";

        if (isset($_SESSION["Carrito"])) {

            foreach ($_SESSION["Carrito"]['Items'] as $rows => $row) {
                if ($_SESSION['CodCarr'] === $row['clien']) {

                    $_SESSION['ModalCarrPro'] = $_SESSION["Carrito"]['Items'];

                    foreach ($_SESSION["productos_obj"] as $key => $Detalle) {


                        if ($_SESSION["L_preci"] === $Detalle["code_lp"]) {



                            $ValDes = 0.0;
                            $preci = 0.0;
                            $preci = $Detalle['saleprice'];
                            $ProdFin = trim($Detalle['code']);
                            $produc = trim($Detalle['code']);
                            $Observacion = $row['Observacion'];
                            $name = trim($Detalle['name']);



                            if (isset($_SESSION['RCruz'])) {
                                foreach ($_SESSION['RCruz'] as $ref) {
                                    if (trim($ref['cliente'] === trim($_SESSION['Cliente']))) {
                                        if (trim($ref['codecli']) === trim($row['Producto'])) {
                                            $produc = $ref['codepro'];
                                            $ProdFin = $ref['codecli'];
                                            $name = trim($ref['descripcli']);
                                            break;
                                        }
                                    }
                                }
                            }



                                $option .=
                                '<tr>
                                <td><input type="number" value="' . $contador . '" placeholder="0"   class="form-control"></td>
                                  <td ><input value="' . $ProdFin . '" type="text" id="inputProducto' . $contador . '" autocomplete="off" class="form-control producs" required ></td>
                                  <td><input value="' . str_replace('"', "", $name) . '" type="text" disabled id="inputDescripcion' . $contador . '" class="form-control" style="font-size:12px;"></td>
                                  <td><input  type="text" value="' . $Observacion . '" id="inputObservacion' . $contador . '" class="form-control" style="font-size:12px;"></td>
                                  <td><input type="number" value="' . $row['Cantidad'] . '" placeholder="0" style="font-size:12px; "  id="inputCantidad' . $contador . '" onchange="ValiCamp(1,' . $contador . ')" onkeyup="total(' . $contador . ')" class="form-control"></td>
                                  <td><input type="text" value="' . $preci . '"  disabled  class="form-control" style="font-size:12px; text-align:right !important;"></td>
                                  <td><input type="text" value="0" placeholder="0" style="font-size:12px; text-align:right !important;" disabled id="inputTotal' . $contador . '" class="form-control val-tot"></td>
                                </tr>';



                                $contador = $contador + 1;

                                break;
                            }

                        }
                    }



                }

            }

        }


        return ($option . "??" . $contador . "??" . $ProdFin . "??" . $produc);
    }


;

echo consulta();
?>
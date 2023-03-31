<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{
    if (isset($_SESSION['CopPed'])) {

        $_SESSION['DetPed'] = $_SESSION['CopPed'];
        include '../../controller/api/ws_verify_DetPediTwo.php';

        $option = null;
        $contador = 1;

        if (isset($_SESSION["DetallePedido"])) {
            $_SESSION['ModalCopPro'] = $_SESSION["DetallePedido"];

            foreach ($_SESSION["DetallePedido"] as $row) {

                foreach ($_SESSION["productos_obj"] as $key => $Detalle) {
                    if ($_SESSION["L_preci"] === $Detalle["code_lp"]) {

                        if (trim($Detalle['code']) === trim($row['productid'])) {

                            $ValDes = 0.0;
                            $preci = 0.0;
                            $preci = $Detalle['saleprice'];
                            $ProdFin = trim($Detalle['code']);
                            $name = trim($Detalle['name']);



                            if (isset($_SESSION['RCruz'])) {
                                foreach ($_SESSION['RCruz'] as $ref) {
                                    if (trim($ref['cliente'] === trim($_SESSION['Cliente']))) {
                                        if (trim($ref['codepro']) === trim($Detalle['code'])) {
                                            $produc = $ref['codepro'];
                                            $ProdFin = $ref['codecli'];
                                            $name = trim($ref['descripcli']);
                                            break;
                                        }
                                    }
                                }
                            }



                            if (isset($_SESSION["DetRegla"])) {
                                foreach ($_SESSION["DetRegla"] as $Reg => $Des) {
                                    if ($Des['group'] === $Detalle['grupop'] && trim($Des['codecli']) === trim($_SESSION['Cliente']) && trim($Des['discountpercentage']) > 0) {
                                        $ValDes = $Des['discountpercentage'];
                                        $podes = $preci * ($ValDes / 100);
                                        $preci = $preci - $podes;
                                        break;
                                    }
                                }
                            }

                            $stock = 0.0;
                            $stock = $Detalle['StockAct'];
    
                            
                            if(isset($_SESSION['CodVen'])){
                                $title='Stock: '.$stock.''; 
                            }else{
                                $title='';
                            }    


                            if ($stock>0){
                                $imgStock='<img src="../../img/stocksi.png" title="'.$title.'" alt="ver" id="stock'. $contador .'" width="20px"></td>';
                            }else{
                                $imgStock='<img src="../../img/stockno.png" title="'.$title.'" alt="ver" id="stock'. $contador .'" width="20px"></td>';
                            }



                            $option .=
                                '<tr id="tr' . $contador . '">
                                  <td><button type="button"  id="delete' . $contador . '" class="form-control"  onclick="eliminarFilaSele(' . $contador . ')" style="border: none"><img src="../../img/menos.png" alt="borrar" width="20px"></button></td>
                                  <td width="18%" id="td' . $contador . '"><input value="' . $ProdFin . '" type="text" id="inputProducto' . $contador . '" autocomplete="off" class="form-control producs" style="font-size:12px;" required onkeyup="SelProd(' . $contador . ')"  list="produc-list' . $contador . '"></td>
                                  <td width="18%"><input value="' . str_replace('"', "", $name) . '" type="text" disabled id="inputDescripcion' . $contador . '" class="form-control" style="font-size:12px;"></td>
                                  <td width="15%"><input value="" type="text" id="inputObservacion' . $contador . '" class="form-control" style="font-size:12px;"></td>
                                  <td width="5%"><input type="number" value="' . $row['quantity'] . '" placeholder="0" style="font-size:12px;"  id="inputCantidad' . $contador . '" onchange="ValiCamp(1,' . $contador . ')" onkeyup="total(' . $contador . ')" class="form-control"></td>
                                  <td><input type="text" value="' . number_format($preci, 2, ',', '.') . '"  disabled placeholder="0" id="inputPrecio' . $contador . '" onchange="ValiCamp(2,' . $contador . ')" onkeyup="total(' . $contador . ')" class="form-control" style="font-size:12px; text-align:right !important;"></td>
                                  <td class="Val-Pre"><input type="number" value="' . $Detalle['saleprice'] . '"  disabled placeholder="0" id="inputPrecio' . $contador . '-ori")" class="form-control Val-Pre" style="font-size:12px;"></td>
                                  <td class="Val-Pre"><input type="number" value="0" placeholder="0" disabled id="inputTotal' . $contador . '-ori" class="form-control val-tot-ori" style="font-size:12px;"></td>                    
                                  <td><input type="text" value="0" placeholder="0" style="font-size:12px; text-align:right !important;" disabled id="inputTotal' . $contador . '" class="form-control val-tot"></td>
                                  <td><button type="button" class="btn" data-bs-toggle="modal" data-bs-target="#Imp' . $contador . '"><img src="../../img/lupa.png" alt="ver" width="20px"></button>
                                  '.$imgStock.'
                                  
                                  </tr>';

                            $contador = $contador + 1;

                            break;
                        }
                    }
                }
            }
        }


        return ($option);
    }

}
;

echo consulta();
?>
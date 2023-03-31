<?php
require_once("../../controller/verification/functions.php");
session_start();
function consulta()
{

    include '../../controller/api/ws_verify_DetPedi.php';
    include '../../controller/api/ws_verify_DetPediTwo.php';

    $option = '<table id="example" class="table table-bordered mt-3">
        <thead style="background-color: #0D729C;color: white;">
            <tr style="font-size:13px;">
                <th scope="col">N°</th>
                <th scope="col">Producto</th>
                <th scope="col">Descripción</th>
                <th scope="col" style="font-size:12px !important;">Cantidad Solicitada</th>
                <th scope="col" style="font-size:12px !important;">Cantidad Entregada</th>
                <th scope="col" style="font-size:13px !important;">Fecha Estimada Despacho</th>
                <th scope="col" >Fecha Despacho</th>
                <th scope="col">Precio Unitario</th>
                <th scope="col">Valor Total</th>
            </tr>
        </thead>
        <tbody>';


    if (isset($_SESSION["DetPedido"])) {
        $DC = 2;
        $SM = '.';
        $SD='.';

        if (isset($_SESSION["DetallePedido"])) {

            $SubTotal = 0;
            $Impuesto = 0;
            $Descuento = 0;
            $ValTota = 0;

            foreach ($_SESSION["DetallePedido"] as $Det) {

                $date = new DateTime($_SESSION["DetPedido"]['emitiondate']);
                $date = $date->format('d/m/Y');
                
                $dateDes = new DateTime($Det['entreg']);
                $dateDes = $dateDes->format('d/m/Y');
                $dateRemi = "";
                if(strlen(trim($Det['dateremito']))>2){
                    $dateRemi = new DateTime($Det['dateremito']);
                    $dateRemi = $dateRemi->format('d/m/Y');
                }

                

                $Descuento += $Det['totaldiscount'];
                $SubTotal += $Det['totalline'];
                $Impuesto += 0;

                $option .= '<tr>
                    <th >' . $Det['item'] . '</th>
                    <td width="10%"><input type="text" title="' . $Det['productid'] . '" placeholder="' . $Det['productid'] . '" class="form-control" disabled style="font-size:12px;"></td>
                    <td width="24%"><input type="text" title="' . $Det['productname'] . '" class="form-control" placeholder="' .str_replace('"',"",$Det['productname']) . '" disabled style="font-size:12px;"></td>
                    <td width="2%"><input type="number" class="form-control" placeholder="' . $Det['quantity'] . '" disabled style="font-size:12px;"></td>
                    <td width="2%"><input type="number" class="form-control" placeholder="' . $Det['cantent'] . '" disabled style="font-size:12px;"></td>
                    <td width="10%"><input type="text" class="form-control" placeholder="' . $dateDes . '" disabled style="font-size:12px;"></td>
                    <td width="10%"><input type="text" class="form-control" placeholder="' . $dateRemi . '" disabled style="font-size:12px;"></td>
                    <td><input type="number" class="form-control" placeholder="$ ' . number_format($Det['saleprice'],$DC,$SM,$SD) . '" disabled style="font-size:12px;text-align:right;"></td>
                    <td><input type="text" class="form-control" placeholder="$ ' . number_format($Det['totalline'],$DC,$SM,$SD) . '" disabled style="font-size:12px;text-align:right;"></td>
                    </tr>';
            }

            $ValTota = $SubTotal-$Impuesto;
            

            $SubTotal += $Descuento;
            
            

            $option .= '</tbody>
                </table>
                </div>
                        <div>
                            <table class="table table-bordered mt-3">
                                <thead>
                                <!--
                                    <tr>
                                        <th width="80%" scope="col" style="text-align: end;">Valor Total</th>
                                        <th><input class="form-control" type="text" style="background-color: white;text-align: end;border: none;font-weight: 700;" placeholder="$ ' . number_format($_SESSION["DetPedido"]['total']) . '" disabled></th>    
                                    </tr>
-->
                                    <tr>
                                        <th scope="col" id="subtotal" class="tides">SubTotal<input style="border:none; text-align:right;" class="form-control" type="text"
                                                id="subtota" placeholder="$ ' . number_format($SubTotal,$DC,$SM,$SD) . '" disabled></th>
                                        <th scope="col" id="ImpuIva" class="tides">Impuestos<input style="border:none; text-align:right;" class="form-control"
                                                    type="text" id="ImpuesIva" placeholder="$ ' . number_format($Impuesto,$DC,$SM,$SD) . '" disabled></th>
                                        <th scope="col" id="GeneDescuentos" class="tides">Descuentos<input style="border:none; text-align:right;" class="form-control" type="text"
                                                id="DescGene" placeholder="$ ' . number_format($Descuento,$DC,$SM,$SD) . '" onkeydown=TotFinal() disabled></th>
                                        <th scope="row" id="total">Valor Total<input style="border:none; text-align:right;" class="form-control" type="text" id="ValTota"
                                        placeholder="$ ' . number_format($ValTota,$DC,$SM,$SD) . '" disabled></th>
                                    </tr>
                                </thead>
                            </table>
                        </div>
                        <div class="col-12">
                    </div>';

        }else {

            $option=999;
            
        }

    } else {
        $option=999;
    }







    return (($date . "??" . $option));


}
;

echo consulta();
?>
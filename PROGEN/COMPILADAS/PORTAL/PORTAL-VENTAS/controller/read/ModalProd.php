<?php
error_reporting(0);
session_start();

if (isset($_SESSION["Productos_File"])) {

    $productos = $_SESSION["Productos_File"];

    $option = null;
    $error = null;
    $contador = 1;
    $produc = null;


    $imputes = 0;
    $nametes = 0;
    $porcimp = 0;
    $ValIva = 0;

    $cant = 0;
    $tot = 0;
    $Impiva = '<tr>    <td></td>    <td></td>    <td></td>    <td></td>  </tr>';
    $riva = '<tr>    <td></td>    <td></td>    <td></td>    <td></td>  </tr>';




    foreach ($productos as $row) {
        if ($row[0] != "Codigo") {

            $produc = strtoupper($row[0]);



            foreach ($_SESSION["productos_obj"] as $key => $Detalle) {
                if ($_SESSION["L_preci"] === $Detalle["code_lp"]) {
                    $fail = 1;
                    $ProdFin = trim(strtoupper($row[0]));



                    if (trim(strtoupper($Detalle['code'])) != trim(strtoupper($produc))) {
                        if (isset($_SESSION['RCruz'])) {
                            foreach ($_SESSION['RCruz'] as $ref) {
                                if (trim($ref['cliente'] === trim($_SESSION['Cliente']))) {
                                    if (trim(strtoupper($ref['codecli'])) === trim(strtoupper($row[0]))) {
                                        $produc = $ref['codepro'];
                                        $ProdFin = $ref['codecli'];
                                        break;
                                    }
                                }
                            }
                        }
                    }

                    if (strlen(trim($ProdFin)) > 0) {
                        if (trim(strtoupper($Detalle['code'])) === trim(strtoupper($produc))) {


                            $ValDes = 0.0;
                            $podes = 0;
                            $cant = $row[2];

                            $preci = 0.0;
                            $preci = $Detalle['saleprice'];
                            $tot = $preci * $cant;

                            if (isset($_SESSION["DetRegla"])) {
                                foreach ($_SESSION["DetRegla"] as $Reg => $Des) {
                                    if ($Des['group'] === $Detalle['grupop'] && trim($Des['codecli']) === trim($_SESSION['Cliente']) && trim($Des['discountpercentage']) > 0) {
                                        $ValDes = $Des['discountpercentage'];
                                        $podes = $preci * ($ValDes / 100);
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
                                $ValIva = $tot * ($porcimp / 100);


                                $Impiva = '<tr>
                                            <td id="CodImp' . $contador . '">' . $imputes . '</td>
                                            <td id="NomImp' . $contador . '">' . $nametes . '</td>
                                            <td>
                                            <input style="border:none;" type="number" required disabled value="' . $porcimp . '" id="PorImp' . $contador . '" autocomplete="off" class="form-control">
                                            </td>
                                            <td>
                                            <input style="border:none; text-align:right;" type="text" required disabled value="' . $ValIva . '" id="TotImp' . $contador . '" autocomplete="off" class="form-control TotImpuIva">
                                            </td>
                                            </tr>';




                            } else {

                                if (isset($_SESSION["ImpIVA"])) {
                                    foreach ($_SESSION["ImpIVA"] as $iva => $Imp) {
                                        if ($Imp['codeprod'] === $produc) {
                                            $imputes = $Imp['imputes'];
                                            $nametes = $Imp['descrimp'];
                                            $porcimp = $Imp['porcimp'];
                                            $ValIva = $tot * ($porcimp / 100);




                                            $Impiva = '<tr>
                                            <td id="CodImp' . $contador . '">' . $imputes . '</td>
                                            <td id="NomImp' . $contador . '">' . $nametes . '</td>
                                            <td>
                                            <input style="border:none;" type="number" required disabled value="' . $porcimp . '" id="PorImp' . $contador . '" autocomplete="off" class="form-control">
                                            </td>
                                            <td>
                                            <input style="border:none; text-align:right;" type="text" required disabled value="' . number_format($ValIva, 2, '.', ',') . '" id="TotImp' . $contador . '" autocomplete="off" class="form-control TotImpuIva">
                                            </td>
                                            </tr>';



                                            break;
                                        }
                                    }
                                }
                            }




                            $option .=
                                '             
                            <div class="modal fade" id="Imp' . $contador . '"  tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
                            <div class="modal-dialog  modal-lg">
                                <div class="modal-content">
                                    <div class="modal-header">
                                        <h5 class="modal-title" style="color:black;" id="exampleModalLabel">Detalle de Impuestos</h5>
                                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                                    </div>
                                    <div class="modal-body">
                                    

                                    <div class="row">

                                    
                                    <div class="form-group row p-3">

                                        <table class="table table-bordered">
                                        <thead>
                                        <tr>
                                        <th>Impuesto</th>
                                        <th>Descripción</th>
                                        <th>Valor %</th>
                                        <th>Valor</th>
                                        </tr>
                                        </thead>
                                        <tbody>
                                        ' . $Impiva . '
                                        </tbody>
                                        </table>


                                    <div class="form-group row">
                                    <label for="delim" class="col-sm-3 col-form-label">Descuento %</label>
                                    <div class="col-sm-7">
                                    <input type="number" required disabled value="' . $ValDes . '" id="inputDescuento' . $contador . '" autocomplete="off" class="form-control">
                                    </div>
                                    <label for="delim" class="col-sm-3 col-form-label">Val Descu</label>
                                    <div class="col-sm-7">
                                    <input type="text" required disabled value="' . number_format($podes, 2, '.', ',') . '" id="totDescuento' . $contador . '" autocomplete="off" class="form-control desc-tot">
                                    </div>           </div>           </div>           </div>                                      
                                    </div>
                                    <div class="modal-footer">
                                    <button type="button" class="btn btn-primary" data-bs-dismiss="modal">Ocultar</button> 
                                    </div>           </div>           </div>           </div>
                               ';
                            $contador = $contador + 1;
                            $Impiva = '<tr>    <td></td>    <td></td>    <td></td>    <td></td>  </tr>';
                            $riva = '<tr>    <td></td>    <td></td>    <td></td>    <td></td>  </tr>';

                            $fail = 0;
                            break;

                        }

                    }

                }

            }

        }



    }


    $_SESSION['Product'] = $option;



    print_r($_SESSION['Product']);
}
?>
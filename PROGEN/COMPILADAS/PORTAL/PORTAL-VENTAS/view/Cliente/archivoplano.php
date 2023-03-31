<?php
// error_reporting(0);
require '../../librerias/Excel/vendor/autoload.php';


$start_time = microtime(true);
session_start();
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Cell\Coordinate;

$destino = 'Excel/';

$nombreArchivo = "duvan.xlsx";
$nombreArchivo = $_FILES['file']['name'];
$Arch = $destino . $nombreArchivo;
$tmp = $_FILES['file']['tmp_name'];

move_uploaded_file($tmp, $destino . $nombreArchivo);


$documento = IOFactory::load($Arch);

$totalHojas = $documento->getSheetCount();

$hojaActual = $documento->getSheet(0);
$numeroFilas = $hojaActual->getHighestDataRow();
$letra = $hojaActual->getHighestColumn();

$numeroLetra = Coordinate::columnIndexFromString($letra);


$option = null;
$error = 0;
$contador = 1;
$produc = null;
$array = array();
$produto = array();
$duva = 0;
$end_time = microtime(true);
$duration = $end_time - $start_time;
$hours = (int) ($duration / 60 / 60);
$minutes = (int) ($duration / 60) - $hours * 60;
$seconds = (int) $duration - $hours * 60 * 60 - $minutes * 60;
$tiempo1 = "Tiempo #1 <strong>" . $hours . ' horas, ' . $minutes . ' minutos y ' . $seconds . ' segundos.</strong>';

$optionTwo = null;
$imputes = 0;
$nametes = 0;
$porcimp = 0;
$ValIva = 0;

$cant = 0;
$tot = 0;
$Impiva = '<tr>    <td></td>    <td></td>    <td></td>    <td></td>  </tr>';
$riva = '<tr>    <td></td>    <td></td>    <td></td>    <td></td>  </tr>';
$fail = null;
$start_time = microtime(true);
if (isset($_SESSION["productos_obj"])) {

    for ($indiceFila = 2; $indiceFila <= $numeroFilas; $indiceFila++) {

        $valora = $hojaActual->getCellByColumnAndRow(1, $indiceFila);
        $valorb = $hojaActual->getCellByColumnAndRow(2, $indiceFila);
        $celda = $hojaActual->getCell('C'.$indiceFila);
        $valorc = $celda->getFormattedValue();

        $produc = strtoupper($valora);
        $duva = 0;
        if (strlen(trim($valora) > 1)) {
            foreach ($_SESSION["productos_obj"] as $key => $Detalle) {

                $duva = $duva + 1;
                $fail = 1;
                $ProdFin = trim(strtoupper($valora));
                $name = trim($Detalle['name']);



                    if (isset($_SESSION['RCruz'])) {
                        foreach ($_SESSION['RCruz'] as $ref) {
                            if (trim($ref['cliente'] === trim($_SESSION['Cliente']))) {
                                if ((trim(strtoupper($ref['codecli'])) === trim(strtoupper($valora)))) {
                                    // || (trim(strtoupper($ref['codepro'])) == trim(strtoupper($row[0])))) {
                                    $produc = $ref['codepro'];
                                    $ProdFin = $ref['codecli'];

                                    if(strlen(trim($ref['descripcli']))>3){
                                        $name = trim($ref['descripcli']);
                                    }
                                    
                                    break;
                                }
                            }
                        }
                    }
                


                if (strlen(trim($ProdFin)) > 0) {
                    if (trim(strtoupper($Detalle['code'])) === trim(strtoupper($produc))) {


                        $ValDes = 0.0;
                        $podes = 0;
                        $preci = 0.0;
                        $preci = $Detalle['saleprice'];
                        $new = 0.0;
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
                       
                       
                        $tot = $preci * $valorc;

                        // if (!isset($_SESSION["DetRegla" . $_SESSION['Cliente']])) {
                        //     include '../../controller/api/ws_verify_ReNego_Cli.php';
                        // }

                        if (isset($_SESSION["DetRegla"])) {
                            foreach ($_SESSION["DetRegla"] as $Reg => $Des) {
                                if ($Des['group'] === $Detalle['grupop'] && trim($Des['codecli']) === trim($_SESSION['Cliente']) && trim($Des['discountpercentage']) > 0) {
                                    $ValDes = $Des['discountpercentage'];
                                    $podes = $preci * ($ValDes / 100);
                                    break;
                                }
                            }
                        }



                        $produto[] = array(trim($valora), trim($valorb), trim($valorc));
                        $_SESSION["Productos_File"] = $produto;
                        $option .=
                            '<tr id="tr' . $contador . '">
                                <td><button type="button"  id="delete' . $contador . '" class="form-control"  onclick="eliminarFilaSele(' . $contador . ')" style="border: none"><img src="../../img/menos.png" alt="borrar" width="20px"></button></td>
                                <td width="18%" id="td' . $contador . '" class="tdcv"><input value="' . $ProdFin . '" type="text" id="inputProducto' . $contador . '" autocomplete="off" class="form-control producs" style="font-size:12px;" required onkeyup="SelProd(' . $contador . ')"  list="produc-list' . $contador . '">
                                </td>
                                <td width="18%"><input value="' . str_replace('"', "", $name) . '" title="' . str_replace('"', "", $name) . '" type="text" disabled id="inputDescripcion' . $contador . '" class="form-control" style="font-size:12px;"></td>
                                <td width="15%"><input value="' . $valorb . '" type="text" id="inputObservacion' . $contador . '" class="form-control" style="font-size:12px;"></td>
                                <td width="5%"><input type="number" value="' . $valorc . '" placeholder="0" style="font-size:12px;"  id="inputCantidad' . $contador . '" onchange="ValiCamp(1,' . $contador . ')" onkeyup="total(' . $contador . ')" class="form-control"></td>
                                <td><input type="text" value="' . number_format($preci, 2, ',', '.') . '"  disabled placeholder="0" id="inputPrecio' . $contador . '" onchange="ValiCamp(2,' . $contador . ')" onkeyup="total(' . $contador . ')" class="form-control" style="font-size:12px; text-align:right !important;"></td>
                                <td class="Val-Pre"><input type="number" value="' . $Detalle['saleprice'] . '"  disabled placeholder="0" id="inputPrecio' . $contador . '-ori")" class="form-control Val-Pre" style="font-size:12px;"></td>
                                <td class="Val-Pre"><input type="number" value="0" placeholder="0" disabled id="inputTotal' . $contador . '-ori" class="form-control val-tot-ori" style="font-size:12px; text-align:right !important;"></td>                    
                                <td><input type="text" value="0" placeholder="0" style="font-size:12px; text-align:right !important;" disabled id="inputTotal' . $contador . '" class="form-control val-tot"></td>
                                <td><button type="button" class="btn" data-bs-toggle="modal" data-bs-target="#Imp' . $contador . '"><img src="../../img/lupa.png" alt="ver" width="20px"></button>
                                '.$imgStock.' 
                                </tr>';



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


                        $optionTwo .=
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
                            <input type="hidden" name="" id="ARC_'.$contador.'" value="'.$Detalle['tes'].'">
                       ';
                        
                        $Impiva = '<tr>    <td></td>    <td></td>    <td></td>    <td></td>  </tr>';
                        $riva = '<tr>    <td></td>    <td></td>    <td></td>    <td></td>  </tr>';







                        $contador = $contador + 1;
                        $fail = 0;
                        break;

                    }
                }



            } // fin foreach
        }
        $end_time = microtime(true);
        $duration = $end_time - $start_time;
        $hours = (int) ($duration / 60 / 60);
        $minutes = (int) ($duration / 60) - $hours * 60;
        $seconds = (int) $duration - $hours * 60 * 60 - $minutes * 60;
        $tiempo2 = "Tiempo #2: <strong>" . $hours . ' horas, ' . $minutes . ' minutos y ' . $seconds . ' segundos.</strong>';

        if (!isset($valorb)) {
            $valorb = null;
        }
        if (!isset($valorc)) {
            $valorc = null;
        }
        if ($fail === 1 && trim($valora) != "") {


            $array[] = array(trim($valora), trim($valorb), trim($valorc));
            $fail = 0;
        }





    } //fin

    if (count($array) > 0) {
        $_SESSION['fail'] = $array;
        $error = 1;

    }

    $_SESSION['Product'] = $option . "??" . $error . "??" . $numeroFilas . "??" . count($array) . "??" . $tiempo1 . "??" . $tiempo2."??".$optionTwo;


    print_r($_SESSION['Product']);
}
 unlink($destino . $nombreArchivo);

?>
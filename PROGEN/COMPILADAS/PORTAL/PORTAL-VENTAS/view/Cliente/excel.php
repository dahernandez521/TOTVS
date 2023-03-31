<?php
require '../../librerias/Excel/vendor/autoload.php';
session_start();
use PhpOffice\PhpSpreadsheet\Spreadsheet;
use PhpOffice\PhpSpreadsheet\IOFactory;
use PhpOffice\PhpSpreadsheet\Cell\Coordinate;

$destino = 'Excel/';
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
$error = null;
$contador = 1;
$produc = null;
$array = array();

if (isset($_SESSION["productos_obj"])) {
    for ($indiceFila = 2; $indiceFila <= $numeroFilas; $indiceFila++) {
        //    for ($indiceColumna=1;$indiceColumna<=$numeroLetra;$indiceColumna++){
//     $valor = $hojaActual->getCellByColumnAndRow($indiceColumna,$indiceFila);
//     $valora = $hojaActual->getCellByColumnAndRow(1,$indiceFila);
//     $valorb= $hojaActual->getCellByColumnAndRow(2,$indiceFila);
//     $valorc = $hojaActual->getCellByColumnAndRow(3,$indiceFila);
//     echo "Producto: ".$valora.' Observacion: '.$valorb.' Cantidad: '.$valorc.' ';
//    }

        $valora = $hojaActual->getCellByColumnAndRow(1, $indiceFila);
        $valorb = $hojaActual->getCellByColumnAndRow(2, $indiceFila);
        $valorc = $hojaActual->getCellByColumnAndRow(3, $indiceFila);

        $produc = strtoupper($valora);
        foreach ($_SESSION["productos_obj"] as $key => $Detalle) {

            if ($_SESSION["L_preci"] === $Detalle["code_lp"]) {
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
                                $name = trim($ref['descripcli']);
                                break;
                            }
                        }
                    }
                }


                if (strlen(trim($ProdFin)) > 0) {
                    if (trim(strtoupper($Detalle['code'])) === trim(strtoupper($produc))) {


                        $ValDes = 0.0;
                        $preci = 0.0;
                        $preci = $Detalle['saleprice'];


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


                        $option .=
                            '<tr id="tr' . $contador . '">
                    <td><button type="button"  id="delete' . $contador . '" class="form-control"  onclick="eliminarFilaSele(' . $contador . ')" style="border: none"><img src="../../img/menos.png" alt="borrar" width="20px"></button></td>
                    <td width="18%" id="td' . $contador . '"><input value="' . $ProdFin . '" type="text" id="inputProducto' . $contador . '" autocomplete="off" class="form-control producs" style="font-size:12px;" required onkeyup="SelProd(' . $contador . ')"  list="produc-list' . $contador . '"></td>
                    <td width="18%"><input value="' . str_replace('"', "", $name) . '" title="' . str_replace('"', "", $name) . '" type="text" disabled id="inputDescripcion' . $contador . '" class="form-control" style="font-size:12px;"></td>
                    <td width="15%"><input value="' . $valorb . '" type="text" id="inputObservacion' . $contador . '" class="form-control" style="font-size:12px;"></td>
                    <td width="5%"><input type="number" value="' . $valorc . '" placeholder="0" style="font-size:12px;"  id="inputCantidad' . $contador . '" onchange="ValiCamp(1,' . $contador . ')" onkeyup="total(' . $contador . ')" class="form-control"></td>
                    <td><input type="text" value="' . number_format($preci, 3, ',', '.') . '"  disabled placeholder="0" id="inputPrecio' . $contador . '" onchange="ValiCamp(2,' . $contador . ')" onkeyup="total(' . $contador . ')" class="form-control" style="font-size:12px; text-align:right !important;"></td>
                    <td class="Val-Pre"><input type="number" value="' . $Detalle['saleprice'] . '"  disabled placeholder="0" id="inputPrecio' . $contador . '-ori")" class="form-control Val-Pre" style="font-size:12px;"></td>
                    <td class="Val-Pre"><input type="number" value="0" placeholder="0" disabled id="inputTotal' . $contador . '-ori" class="form-control val-tot-ori" style="font-size:12px; text-align:right !important;"></td>                    
                    <td><input type="text" value="0" placeholder="0" style="font-size:12px; text-align:right !important;" disabled id="inputTotal' . $contador . '" class="form-control val-tot"></td>
                    <td><button type="button" class="btn" data-bs-toggle="modal" data-bs-target="#Imp' . $contador . '"><img src="../../img/lupa.png" alt="ver" width="20px"></button></td> </tr>';

                        $contador = $contador + 1;
                        $fail = 0;
                        break;

                    }
                }

            }



        }
        if (!isset($valorb)) {
            $valorb = null;
        }
        if (!isset($valorc)) {
            $valorc = null;
        }
        if ($fail === 1 && trim($valora) != "") {

            
            $array[] = array(trim($valora), trim($valorb),trim($valorc));
            $fail = 0;
        }





    }

    if(count($array)>0){
        $_SESSION['fail'] = $array;
        echo "<script> window.open('error.php'); </script>";
    }

    $_SESSION['Product'] = $option . "??" . $error . "??" . $numeroFilas;


    print_r($_SESSION['Product']);
}
unlink($destino . $nombreArchivo);

?>
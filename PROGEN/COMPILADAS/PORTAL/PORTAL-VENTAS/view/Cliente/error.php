<?php
require_once("../../controller/verification/functions.php");
session_start();
require '../../librerias/Excel/vendor/autoload.php';

use PhpOffice\PhpSpreadsheet\Spreadsheet;
// use PhpOffice\PhpSpreadsheet\writer\Xlsx;
use PhpOffice\PhpSpreadsheet\IOFactory;


$spreadsheet = new Spreadsheet();

$spreadsheet->setActiveSheetIndex(0);

$spreadsheet->getProperties()
    ->setCreator("TOTVS MEXICO")
    ->setLastModifiedBy("Protehus - Progen")
    ->setTitle("Resumen Fails Items")
    ->setSubject("Plantilla de Items fallidos portal de ventas Protheus TOTVS")
    ->setDescription(
        "TOTVS MEXICO - PORTAL VENTAS PROGEN"
    );


$hojaActiva = $spreadsheet->getActiveSheet();
$spreadsheet->getDefaultStyle()->getFont()->setName("Resumen Fails Items");
$hojaActiva->setTitle("ITEMS PEDIDO DE VENTA");
$spreadsheet->getDefaultStyle()->getFont()->setSize(11);
$hojaActiva->getColumnDimension('A')->setWidth(30);
$hojaActiva->getColumnDimension('B')->setWidth(40);

$hojaActiva->setCellValue('A1', 'CODIGO');
$hojaActiva->setCellValue('B1', 'OBSERVACION');
$hojaActiva->setCellValue('C1', 'CANTIDAD');
$cont = 2;
foreach ($_SESSION['fail'] as $row) {
    $hojaActiva->setCellValue('A'.$cont, $row[0]);
    $hojaActiva->setCellValue('B'.$cont, $row[1]);
    $hojaActiva->setCellValue('C'.$cont, $row[2]);
    $cont++;
}
header('Content-Type: application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
header('Content-Disposition: attachment;filename="ITEMS FAIS TOTVS.xlsx"');
header('Cache-Control: max-age=0');

$writer = IOFactory::createWriter($spreadsheet, 'Xlsx');
$writer->save('php://output');




?>

<?php
use Dompdf\Dompdf;

$dompdf = new DOMPDF();
$dompdf->setPaper('A4', 'landscape');
$dompdf->loadhtml(ob_get_clean());
$dompdf->render();
header("Content-type: application/pdf");
header("Content-Disposition: inline; filename=documento.pdf");
$pdf = $dompdf->output();
$filename = "Cotizacion.pdf";
file_put_contents($filename, $pdf);

// $dompdf->stream($filename, ['Attachment' => false]);
$dompdf->stream($filename);


unlink($filename);


?>
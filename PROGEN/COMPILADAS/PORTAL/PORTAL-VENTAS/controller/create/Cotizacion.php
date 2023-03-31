<?php
require_once '../../html2pdf/autoload.inc.php';
require_once '../../html2pdf/autoload.php';
use Dompdf\Dompdf;
use Dompdf\Options;
function pdfNo($id)
{


    $options = new Options();

    $options->set('isHtml5ParserEnabled', true);
    $options->set('isRemoteEnabled', true);

    $dompdf = new Dompdf($options);
    $dompdf->loadHtml(ob_get_clean());


    $dompdf->setPaper('A4', 'landscape');
    $dompdf->render();
    $pdf = $dompdf->output();
    $filename = "../../pdf/Reporte" . $id . ".pdf";
    file_put_contents($filename, $pdf);
    $dompdf->stream($filename, ["Attachment" => true]);
    // unlink($filename);

  


}





?>
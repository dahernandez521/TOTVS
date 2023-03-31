<?php

$option = null;
$MC = null;
$ValTot = 0;
$SalTot = 0;
$LimCred = 0;
$notas = 0;
$cabeza = '<table id="example" class="table table-striped table-bordered mt-3">
        <thead style="background-color: #0D729C;color: white;">
            <tr>
            <th scope="col">Tipo de Documento</th>
            <th scope="col">Número</th>
            <th scope="col">Fec Emisión</th>
            <th scope="col">Fec Venc </th>
           
            <th scope="col">Ult Trans</th>
            <th scope="col">Valor Total</th>
            <th scope="col">Saldo</th>
            <th scope="col"></th>
            </tr>
        </thead>
        <tbody id="cuerpoTabla">

        ';

if (isset($_SESSION['Cliente'])) {
    if (isset($_SESSION['Cartera'])) {
        // $_SESSION['Cartera']=array_unique($_SESSION['Cartera']);

        $_SESSION['Cartera'] = array_map("unserialize", array_unique(array_map("serialize", $_SESSION['Cartera'])));


        foreach ($_SESSION["Cartera"] as $row) {

            if (trim($row['codclient']) === trim($_SESSION['Cliente'])) {

                $date = new DateTime($row['emission date']);
                $emision = $date->format('d-m-Y');

                $date = new DateTime($row['realexpirationdate']);
                $realexpirationdate = $date->format('d-m-Y');

                $date = new DateTime($row['expirationdate']);
                $expirationdate = $date->format('d-m-Y');

                $date = new DateTime($row['lasttrans']);
                $lasttrans = $date->format('d-m-Y');

                $date = new DateTime($row['paidinfulldate']);
                $paidinfulldate = $date->format('d-m-Y');

                switch (TRIM($row['tipo'])) {
                    case "NF":
                        $Serie = "FACTURA";
                        $valor = $row['totalamount'];
                        $saldo = $row['balancedue'];
                        break;
                    case "NCC":
                        $Serie = "NOTA CREDITO";
                        $valor = $row['totalamount'] * -1;
                        $saldo = $row['balancedue'] * -1;
                        $notas = $row['balancedue'];
                        break;
                    case "NDC":
                        $Serie = "NOTA DEBITO";
                        $valor = $row['totalamount'];
                        $saldo = $row['balancedue'];

                        break;
                    case "RA":
                        $Serie = "RECIBO DE CAJA";
                        $valor = $row['totalamount'] * -1;
                        $saldo = $row['balancedue'] * -1;
                        break;
                    default:
                        $Serie = "4";
                        $valor = $row['totalamount'];
                        $saldo = $row['balancedue'];
                }







                $option .= '<tr>


                <td>' . $row['tipo'] . ' - '.$Serie.'</td>
                <td  style="text-align:right;">' . $row['invoicenum'] . '</td>
                <td style="text-align:right;">' . $emision . '</td>
                <td style="text-align:right;">' . $expirationdate . '</td>
                
                <td style="text-align:right;">' . $lasttrans . '</td>
                <td class="valTot" style="border:none; text-align:right;">' . number_format($row['totalamount'], 2, ',', '.') . '</td>
                <td class="valTot" style="border:none; text-align:right;">' . number_format($row['balancedue'], 2, ',', '.') . '</td>
                <td><button type="button" class="btn" data-bs-toggle="modal" data-bs-target="#Car' . $row['invoicenum'] . '"><img src="../../img/lupa.png" alt="ver" width="20px"></button></td>

                </tr>';
                $ValTot = $ValTot + $valor;
                $SalTot = $SalTot + $saldo;

            }

        }
        $LimCred = $row['limcredit'];
        foreach ($_SESSION["Cartera"] as $row) {

            foreach ($_SESSION["Fpago"] as $Fpa) {

                if (trim($Fpa['code']) === (trim($row['terpago']))) {
                    $CodFp = $Fpa['code'];
                    $NomFp = $Fpa['name'];


                }else{
                    $CodFp="";
                    $NomFp="No hay Forma de Pago asociado.";
                }
            }

            if (trim($row['codclient']) === trim($_SESSION['Cliente'])) {
                $MC .= ' <div class="modal fade" id="Car' . $row['invoicenum'] . '" tabindex="-1" aria-labelledby="exampleModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="exampleModalLabel">DETALLE</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        Serie: ' . $row['tipo'] . '
                        <br>
                        Numero: ' . $row['invoicenum'] . '
                        <br>
                        Forma de Pago: ' . $CodFp . ' - ' . $NomFp . '
                    
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <!--  <button type="button" class="btn btn-primary">Save changes</button> -->
                    </div>
                </div>
            </div>
        </div>';
            }
        }
    }
}
$fotter = '</tbody>
        </table>';

$Total = '<div class="dt-bootstrap4 no-footer mt-3">
        <table class="table table-bordered mb-3">
            <thead>
                <tr>
                <th>limite de Credito</th>
                <th><input class="form-control" type="text"
                        style="background-color: white;border: none; font-weight: 700; text-align:right;"
                        placeholder="$' . number_format($LimCred, 2, ',', '.') . '" disabled id="ValTota"></th>


                <th>Saldo Total</th>
                    <th><input class="form-control" type="text"
                            style="background-color: white;border: none;font-weight: 700; text-align:right;"
                            placeholder="$' . number_format($SalTot, 2, ',', '.') . '" disabled id="ValTot"></th>

                <th>Cupo Disponible</th>
                            <th><input class="form-control" type="text"
                                    style="background-color: white;border: none;font-weight: 700; text-align:right;"
                                    placeholder="$' . number_format($LimCred-$SalTot, 2, ',', '.') . '" disabled id="ValTot"></th>
        
                                            
                </tr>
            </thead>
        </table>
    </div>';


?>
<?php


    $option = '<table id="example" class="table table-striped table-bordered mt-3">
        <thead style="background-color: #0D729C;color: white;">
            <tr>
                <th scope="col"></th>
                <th scope="col">Número</th>
                <th scope="col">Cliente Entr</th>
                <th scope="col">Dirección de Entrega</th>
                <th scope="col">Fecha Generación</th>
                <th scope="col">Valor Total</th>
                <th scope="col">Acciones</th>
            </tr>
        </thead>
        <tbody id="cuerpoTabla">

        ';


    if (isset($_SESSION["Pedidos"])) {
        foreach ($_SESSION["Pedidos"] as $row) {
            $date = new DateTime($row['emitiondate']);
            $date = $date->format('d-m-Y');


            switch (trim($row['estado'])) {
                case "APROBADO":
                    $img = "wms.png";
                    $title = "Aprobado";
                    break;
                case "CERRADO":
                    $img = "facturado.png";
                    $title = "Cerrado";
                    break;
                case "ABIERTO":
                    $img = "aprobado.png";
                    $title = "Abierto";
                    break;
                case "BLOQUEADO":
                    $img = "credito.png";
                    $title = "Bloqueado";
                    break;
                default:
                    $img = "NA.png";
                    $title = "Sin Especificar";
            }




            $option .= '<tr>
                <th scope="row"><img src="../../img/estados/' . $img . '" title="'.$title.'" alt="estado" width="20px"></th>
                <td>' . $row['code'] . '</td>
                <td>' . $row['codclientent'] . '</td>
                <td>' . $row['adressent'] . '</td>
                <td style="text-align:right;">' . $date . '</td>
                <td style="text-align:right;">' . number_format($row['total'],2,',','.') . '</td>
                <td><a id="' . $row['code'] . '" onclick="EnvioPost(this)" href="#"><img src="../../img/lupa.png" title="Ver" alt="" srcset="" width="20px"></a>
                    <a id="' . $row['code'] . '" onclick="EnviCopia(this)" href="#" class="ml-2"><img src="../../img/copia.png" title="Copiar" alt="copiar" width="24px"></a>
                </td>
                </tr>';
        }
    }

    $option .= '</tbody>
        </table>';

?>
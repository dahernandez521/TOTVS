<?php


    


    if (isset($_SESSION["Carrito"])) {
        $cont=0;

        foreach ($_SESSION["Carrito"] as  $row=>   $column) {
            $cont++;

            if(is_numeric($column) ){
            $option .= '<tr>
                <td>' . $cont . '</td>
                <td>' . $column . '</td>
                <td><a id="' . $column. '" onclick="PedCarr(this)"  href="#"><img src="../../img/pedido.png" title="Ver" alt="" srcset="" width="20px"></a></td>
                </tr>';
            }
        }
    }



?>
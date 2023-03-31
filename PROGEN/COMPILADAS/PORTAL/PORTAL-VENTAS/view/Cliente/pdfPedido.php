<?php
include_once "../../dompdf/vendor/autoload.php";

if (session_status() == PHP_SESSION_NONE) {
    session_start();
}

if (isset($_POST['Obs'])) {
    $obs = $_POST['Obs'];
} else {
    $obs = 'Pedido sin Observación';
}

if (isset($_POST['Dir'])) {
    $dir = $_POST['Dir'];
} else {
    $dir = 'Pedido sin Direccion de Entrega';
}




// $_SESSION['Obs'] = $obs;
// $_SESSION['Dir'] = $dir;

if (isset($_SESSION['Obs'])) {
    $obs = $_SESSION['Obs'];
} else {
    $obs = 'Pedido sin Observación';
}

if (isset($_SESSION['Dir'])) {
    $dir = $_SESSION['Dir'];
} else {
    $dir = 'Pedido sin Direccion de Entrega';
}

if (isset($_SESSION['namefan'])) {
    $name = $_SESSION['namefan'];
} else {
    $name = 'Pedido sin nombre de cliente';
}

if (isset($_SESSION['Cliente'])) {
    $cliente = $_SESSION['Cliente'];
} else {
    $cliente = 'Pedido sin cliente de Entrega';
}
date_default_timezone_set("America/Bogota");


if (isset($_SESSION['DateCoti'])) {
    $date = $_SESSION['DateCoti'];
} else {
    $date = date('d-m-Y H:i');
}


if (isset($_SESSION["CotizInd"])) {
    if (!isset($_POST['Tipo'])) {
        $_SESSION["Carrito"] = $_SESSION["CotizInd"];
    }
}

ob_start();
?>
<!DOCTYPE html>
<html lang="en">

<head>
    <!-- <script src="../../js/jquery-3.6.1.min.js"></script> -->
    <link rel="stylesheet" type="text/css" href="../../css/Crear_Pedido.css">
    <link rel="stylesheet" href="../../css./fuente_raleway.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/twitter-bootstrap/4.1.3/css/bootstrap.css">
    <script src="../../js/jquery-3.6.1.min.js"></script>


    <style>
        .Enc td {
            border: black 3px solid;
        }

        .Enc thead {
            border: black 3px solid;
        }

        #Cab td {
            border: none !important;
            text-align: center;

        }

        .Tex {
            padding-top: 40px !important;
            font-weight: bold;
            font-size: 20px;

        }

        #Cab {
            border: black 3px solid;
        }

        #Cab th {
            padding-left: 150px;
            padding-top: 10px !important;
            ;


        }

        .img {
            padding-right: 250px;
            float: right;
            width: 20%;


        }

        .Enc tbody tr td {
            border: none !important;
        }

        .two {
            margin-top: 20px;
            margin-bottom: 10px;

        }

        .datos {
            padding-right: 80px;
        }

        .Nom {
            font-weight: bold !important;
            font-size: 17px !important;

        }

        table input {
            border: none !important;
            width: auto;
            height: auto;
        }

        #DivTab {
            float: right;
        }

        .header {
            position: absolute;

        }

        #divTabla {
            margin-top: 25px !important;
        }

        .footer {
            /* margin-top: 100px ; */
            position: absolute;
            float: right;
        }

        @page {
            margin: 25px 25px 35px;
        }


        img {
            width: 190px !important;

        }

        #watermark {
            position: fixed;
            bottom: 4cm;
            left: 15%;
            z-index: -1000;
            opacity: 0.06;

            -webkit-transform: rotate(-60deg);
            -moz-transform: rotate(-60deg);
            -o-transform: rotate(-60deg);
            transform: rotate(-60deg);

            font-size: 40pt;
            text-align: center;
        }
    </style>
</head>

<body>


    <div id="watermark">
        <h1>Cotización de Venta</h1>
    </div>

    <div class="container header" style="margin-bottom:200px !important ;">

        <div class="row" style="float:left; font-size: 10pt;">
            <?php
            include '../../img/img.php';
            ?>

            <p style="width:20% !important; text-align: center; margin-left: 18%; font-weight: bold;">
                NIT: 860016310-9
                www.progen.com.co
                contralor@progen.com.co
            </p>

        </div>
        <div class="row tworow" style="float:left;  font-size: 9pt;">

            <p style="width:20% !important; text-align: center; margin-left:90px !important; font-weight: bold;">
                RESPONSABLE DE I.V.A
            </p>
            <p style="width:30% !important; text-align: center; margin-left:40px !important;">
                Actividad Económica Principal 2821 <br>
                <b>NO EFECTUAR RETENCION A TITULO DE RENTA E ICA
                    AUTORRETENEDOR RENTA RESOLUCION 000041 JULIO 16/1992
                    AUTORRETENEDOR ICA RESOLUCION 01 ENERO 2/2017</b>
            </p>

            <p style="width:40% !important; text-align: center;">
                Consulte nuestra Politica de Proteccion de Datos en www.progen.com.co

            </p>

        </div>


        <div class="row" style="float: left !important; font-size: 10pt; margin-left:500px !important;">



            <p style=" text-align: left;">
                CARRERA 3 56 07<br>
                SOACHA CUNDINAMARCA CO<br>
                Código Postal 250052<br>
                PBX: 3102301523<br>
                Ventas: 57 1 7306090 / 57 1<br>
                7306119
                <br>


            </p>
            <B>COTIZACIÓN #
                <?php if (isset($_SESSION['NumCot'])) {
                    echo $_SESSION['NumCot'];
                } ?>
            </B>


        </div>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>

        <br>
        <hr style="color: black; background-color: blue; width:100%;" />
        <div class="row" style="float:left; font-size: 10pt; margin-top:-20px;">

            <p style="width:100% !important; margin-left:-50%">
                <b> OPCIONES PARAREALIZAR EL PAGO. IMPORTANTE: Envíar el soporte del pago al correo
                    cartera@progen.com.co</b> <br>
                Por PSE ingresando a nuestra web www.progen.com.co o consignacion a las cuentas:<br>
                BANCOLOMBIA Cta. Corriente No. 13803226741 Recaudo Empresarial Convenio 3319<br>
                DAVIVIENDA cuenta Ahorros No. 0004900108079 Convenio 0049108079<br>
                BANCOBOGOTA Cta. Corriente No.123282188 Formato Sistema Nacional Rec. Empresarial

            </p>


        </div>
        <hr style="color: black; background-color: blue; width:100%; margin-top:75px;" />

        <div class="container divtwo">
            <table class="table  mt-2 Enc">

                <tbody>

                    <tr>
                        <td class="Nom">Cliente:</td>
                        <td class="datos">
                            <?php echo $cliente ?>
                        </td>
                        <td class="Nom">Nombre:</td>
                        <td>
                            <?php echo $name ?>
                        </td>
                    </tr>
                    <tr>
                        <td class="Nom">Fecha:</td>
                        <td>
                            <?php


                            if (isset($_SESSION['CodCarr'])) {

                                if (isset($_SESSION["Carrito"])) {

                                    echo $_SESSION["Carrito"]['Date'];

                                }
                            }
                            ?>
                        </td>
                        <td class="Nom">Direccion:</td>
                        <td>
                            <?php
                            if (isset($_SESSION['CodCarr'])) {

                                if (isset($_SESSION["Carrito"])) {

                                    echo $_SESSION["Carrito"]['DireccionEnt'];

                                }
                            }
                            // echo $dir ?>
                        </td>
                    </tr>

                </tbody>

            </table>
            <table class="table  mt-6 Enc">
                <tbody>
                    <tr>
                        <td class="Nom">Observacion:</td>
                        <td>
                            <?php


                            if (isset($_SESSION['CodCarr'])) {

                                if (isset($_SESSION["Carrito"])) {

                                    echo $_SESSION["Carrito"]['MessageForNote'];

                                }
                            }
                            ?>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>
        <br>
        <br>
        <br>
        <br>
        <br>
        <br>

        <br>
    </div>
    <br>
    <br>
    <br>
    <br>
    <br>
    <br>

    <br><br>
    <br>
    <br>
    <br>
    <br>
    <br>

    <br>
    <br>

    <br>

    <div class="col-12" id="divTabla">
        <table border="1" style="width:100%" class="table table-bordered mt-3" id="tablaprueba">
            <thead style="background-color: #0D729C;color: white;">
                <tr>
                    <th>Item</th>
                    <th>Producto</th>
                    <th>Nombre</th>
                    <th style="min-width: 100px;">Observación</th>
                    <th>Cantidad</th>

                    <th>Precio Uni</th>
                    <th>% Desc</th>
                    <th>Valor Total</th>
                </tr>
            </thead>
            <tbody id="tbody">
                <?php
                if (isset($_SESSION['CodCarr'])) {

                    $option = null;
                    $contador = 1;
                    $ProdFin = "";
                    $produc = "";
                    $SubTotal = 0.0;
                    $ValIva = 0.0;
                    $Impuesto = 0.0;
                    $Descuentos = 0.0;
                    $Total = 0.0;
                    $decimales = 3;
                    $SM = '.';
                    $SD = ',';


                    if (isset($_SESSION["Carrito"])) {

                        foreach ($_SESSION["Carrito"]['Items'] as $rows => $row) {


                            if ($_SESSION['CodCarr'] === $row['clien']) {

                                $_SESSION['ModalCarrPro'] = $_SESSION["Carrito"]['Items'];

                                foreach ($_SESSION["productos_obj"] as $key => $Detalle) {


                                    if ($_SESSION["L_preci"] === $Detalle["code_lp"]) {



                                        $ValDes = 0.0;
                                        $preci = 0.0;
                                        $Tot = 0.0;
                                        $porcimp = 0.0;
                                        $podes = 0.0;
                                        $preciOne = 0.0;
                                        $preci = $Detalle['saleprice'];
                                        $preciOne = $Detalle['saleprice'];


                                        $ProdFin = trim($row['Producto']);
                                        $produc = trim($row['Producto']);
                                        $Observacion = $row['Observacion'];
                                        $name = trim($Detalle['name']);



                                        if (isset($_SESSION['RCruz'])) {
                                            foreach ($_SESSION['RCruz'] as $ref) {
                                                if (trim($ref['cliente'] === trim($_SESSION['Cliente']))) {
                                                    if (trim($ref['codecli']) === trim($row['Producto'])) {
                                                        $produc = $ref['codepro'];
                                                        $ProdFin = $ref['codecli'];
                                                        $name = trim($ref['descripcli']);
                                                        break;
                                                    }
                                                }
                                            }

                                        }
                                        if (isset($_SESSION["DetRegla"])) {
                                            foreach ($_SESSION["DetRegla"] as $Reg => $Des) {
                                                if ($Des['group'] === $Detalle['grupop'] && trim($Des['codecli']) === trim($_SESSION['Cliente']) && trim($Des['discountpercentage']) > 0) {
                                                    $ValDes = $Des['discountpercentage'];
                                                    $podes = $preci * ($ValDes / 100);
                                                    $preci = $preci - $podes;
                                                    $podes = ($preciOne * $row['Cantidad']) * ($ValDes / 100);

                                                    break;
                                                }
                                            }
                                        }
                                        $Tot = $preci * $row['Cantidad'];


                                        if (isset($_SESSION["ImpIVA"])) {
                                            foreach ($_SESSION["ImpIVA"] as $iva => $Imp) {
                                                if ($Imp['codeprod'] === $produc) {
                                                    $imputes = $Imp['imputes'];
                                                    $nametes = $Imp['descrimp'];
                                                    $porcimp = $Imp['porcimp'];
                                                    $ValIva = $Tot * ($porcimp / 100);

                                                    break;
                                                }
                                            }
                                        }


                                        if (trim(strtoupper($Detalle['code'])) === trim(strtoupper($produc))) {
                                            echo
                                                '<tr>
                                                <td><input type="text" value="' . $contador . '"   class="form-control"></td>
                                                <td ><input value="' . $ProdFin . '" type="text"  autocomplete="off" class="form-control "  ></td>
                                                <td><input value="' . str_replace('"', "", $name) . '" type="text" class="form-control" ></td>
                                                <td><input  type="text" value="' . $Observacion . '"  class="form-control" ></td>
                                                <td><p align="center">' . $row['Cantidad'] . '</p></td>
                                               
                                                <td><p align="right">' . number_format($preciOne, $decimales, $SD, $SM) . '</p></td>
                                                <td><p align="center">' . $ValDes . '</p></td>
                                                <td><p align="right">' . number_format($Tot, $decimales, $SD, $SM) . '</p></td>
                                            </tr>';

                                            $contador = $contador + 1;
                                            $SubTotal += $preciOne * $row['Cantidad'];
                                            $Impuesto += $ValIva;
                                            $Descuentos += $podes;
                                            $Total = $SubTotal + $Impuesto - $Descuentos;

                                            break;
                                        }
                                    }

                                }
                            }

                        }

                    }

                }


                ?>
            </tbody>
        </table>
    </div>


    <div class="text-center p-3 footer">
        <div class="col-12" id="DivTab">
            <table border="1" class="table table-bordered mt-3" id="tablaprueba">
                <thead style="background-color: #0D729C;color: white;">

                    <tr>
                        <th scope="col" id="subtotal" class="tides">SubTotal</th>
                        <th scope="col" id="ImpuIva" class="tides">Impuestos</th>
                        <th scope="col" id="GeneDescuentos" class="tides">Descuentos</th>
                        <th scope="row" id="total">Valor Total</th>
                    </tr>
                </thead>
                <tbody>
                    <tr>
                        <td>
                            <p align="right">$
                                <?php echo number_format($SubTotal, $decimales, $SD, $SM); ?>
                            </p>
                        </td>
                        <td>
                            <p align="right">$
                                <?php echo number_format($Impuesto, $decimales, $SD, $SM); ?>
                            </p>
                        </td>
                        <td>
                            <p align="right">$
                                <?php echo number_format($Descuentos, $decimales, $SD, $SM); ?>
                            </p>
                        </td>
                        <td>
                            <p align="right">$
                                <?php echo number_format($Total, $decimales, $SD, $SM); ?>
                            </p>
                        </td>

                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</body>
<?php
include "dompdf.php";
?>

</html>
<?php
error_reporting(0);
require_once ("../../controller/verification/functions.php");

session_start();


valida_sesion();

include 'homeTop.php';
?>
<head>
    <link rel="stylesheet" type="text/css" href="../../css/Inicio_Seguimiento.css">
    <link rel="stylesheet" href="../../css./fuente_raleway.css">
</head>
    <div class="container-fluid p-5 row">
        <div class="col-12" id="divTitulo">
            <h4 style="font-size: 27px;">Consultar seguimiento pedidos</h4>
        </div>
        <div class="col-12 mt-4">
            <form class="row">
                <div class="row col-md-6">
                    <div class="col-md-5">
                        <label for="inputBusquedaPedido" class="form-label">Busqueda por código de Pedido:</label>
                    </div>
                    <div class="col-md-7">
                        <select class="form-select" aria-label="Default select example">
                            <option selected>Seleccione o busque un pedido</option>
                            <option value="1">000001</option>
                            <option value="2">000002</option>
                            <option value="3">000003</option>
                        </select>
                    </div>
                </div>
                <div class="col-md-6">
                    <a type="submit" class="btn" id="buttonBusqueda">Buscar</a>
                </div>
            </form>
        </div>

    </div>

    <?php
include 'homebott.php'
?>
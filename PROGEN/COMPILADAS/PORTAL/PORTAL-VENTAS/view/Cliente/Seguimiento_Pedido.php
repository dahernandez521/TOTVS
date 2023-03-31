<?php

require_once("../../controller/verification/functions.php");

session_start();

valida_sesion();

include 'homeTop.php';
?>

<head>
    <link rel="stylesheet" type="text/css" href="../../css/Seguimiento_Pedido.css">
    <link rel="stylesheet" href="../../css./fuente_raleway.css">
</head>
<div class="container-fluid p-5">
    <div class="mb-3" id="divTitulo1">
        <h4><a href="./Consultar_Pedidos.php">Pedidos</a> / Seguimiento Pedido</h4>
    </div>
    <div class="alert alert-primary" role="alert">
        <img src="../../img/cheque.png" alt="" width="20px">
        ¡Excelente! El pedido ya fue confirmado, se encuentra en producción
    </div>
    <div class="card">
        <div class="card-header" id="card-header">
            <b id="card-header-titulo">Pedido N° 0000001</b>
        </div>
        <div class="card-body">
            <form class="row" id="form">
                <div class="col-md-3">
                    <label for="inputCliente" class="form-label">Cliente</label>
                    <input type="text" class="form-control" id="inputCliente" placeholder="Giaconno Guzzoni" disabled>
                </div>
                <div class="col-md-3">
                    <label for="inputSucursal" class="form-label">Sucursal</label>
                    <input type="text" class="form-control" id="inputSucursal" placeholder="01" disabled>
                </div>
                <div class="col-md-6">
                    <label for="inputDireccion" class="form-label">Dirección de entrega</label>
                    <input type="text" class="form-control" id="inputDireccion" placeholder="Cra 7 # 116 - 50" disabled>
                </div>
            </form>
        </div>
    </div>
    <div class="card mb-4">
        <div class="card-header" id="card-header">
            <img src="../../img/camion.png" alt="" width="35px" class="mr-3">
            <b id="card-header-titulo">Entrega estimada: 3 - 4 días hábiles</b>
        </div>
        <div class="card-body">
            <h5 class="card-title">Seguimiento</h5>
            <p class="card-text"><img src="../../img/listo.png" alt="check" width="25px" id="check">Pedido Generado el
                11/07/2022
            </p>
            <p class="card-text"><img src="../../img/listo.png" alt="check" width="25px" id="check">Pedido Confirmado
                para
                producción
            </p>
            <p class="card-text"><img src="../../img/circunferencia.png" alt="" width="25px" id="check">Pedido
                Producido</p>
            <p class="card-text"><img src="../../img/circunferencia.png" alt="" width="25px" id="check">Pedido Listo
            </p>
        </div>
    </div>
</div>


<?php
    include 'homebott.php'
?>
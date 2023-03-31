<?php

//cambiar ip publica
$ip = "190.60.28.46";
  $ip = "10.0.0.5";

//cambiar puerto
$puerto=":8095";


$_empresa = "http://" . $ip . $puerto."/rest/api/framework/environment/v1/companies";
$_sucursal = "http://" . $ip . $puerto."/rest/api/framework/environment/v1/branches";
$_verCliente = "http://" . $ip . $puerto."/rest/UANDCLIE/VERCCLIENT";
$_login = "http://" . $ip . $puerto."/rest/UANDLOGIN"; //?USR=AXEL.DIAZ@TOTVS.COM&PWD=12345"
$_maite = "http://" . $ip . $puerto."/rest/UANDPROD/VerProducto"; //prodcutos
$_DetClien = "http://" . $ip . $puerto."/rest/UANDCLIE/VercClient"; //CLIENTES X VENDEDOR
$_clienVend = "http://" . $ip . $puerto."/rest/UANDCLIEXV/VerCliexVen"; //CLIENTES X VENDEDOR
$_clienUsua = "http://" . $ip . $puerto."/rest/UANDCLIEXU/VerCliexUsu"; //CLIENTES X USUARIO
$_Lpreci = "http://" . $ip . $puerto."/rest/UANDLPDET/VerLprecDet"; //LISTA DE PRECIOS
$_ConPed = "http://" . $ip . $puerto."/rest/UANDPVENC/VerPedEnc"; // ENCABEZADO PEDIDOS
$_ConPedTwo = "http://" . $ip . $puerto."/rest/UANDPEDES/VerPedEstat"; // ENCABEZADO PEDIDOS
$_CrePed = "http://" . $ip . $puerto."/rest/UANDPVCRE/CrePedido"; // CREAR PEDIDOS
$_DetPed = "http://" . $ip . $puerto."/rest/UANDPVDET/VerPedDet"; //DETALLE PEDIDO
$_Modali = "http://" . $ip . $puerto."/rest/UANDMODA/VerModalid"; //MODALIDADES
$_Depart = "http://" . $ip . $puerto."/rest/UANDDEPA/VerDeptos"; //DEPARTAMENTOS
$_Municip = "http://" . $ip . $puerto."/rest/UANDMUNI/VerMunicipios"; //DEPARTAMENTOS
$_Fpago = "http://" . $ip . $puerto."/rest/UANDCONDPG/VerCondPag"; //FORMAS DE PAGO
$_Rnego = "http://" . $ip . $puerto."/rest/UANDREDDET/VerRegDDet"; // REGLAS DE NEGOCIO 
$_Carte = "http://" . $ip . $puerto."/rest/UANDCART/VerCartera"; // CARTERA
$_RCruza = "http://" . $ip . $puerto."/rest/UANDREFCRU/VerRefCru"; // Referencia Cruzada
$_Impues = "http://" . $ip . $puerto."/rest/UANDCCIVA/VerIvaProd"; // Impuesto IVA
$_Email = "http://" . $ip . $puerto."/rest/UANDVMAIL/VerInMail"; // Validar Email
$_UpPas = "http://" . $ip . $puerto."/rest/UANDUPPAS/UpdPass"; // Validar Email

?>
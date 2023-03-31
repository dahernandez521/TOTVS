<?php

require_once ("../../controller/verification/functions.php");

session_start();
$_SESSION["salida"]=2;
valida_sesion(); //Valida si hay ua sesion creada, en caso que no sea asi se devuelve al index


// print_r($_SESSION["login"]);

include 'homeTop.php';
include 'homebott.php'

	?>
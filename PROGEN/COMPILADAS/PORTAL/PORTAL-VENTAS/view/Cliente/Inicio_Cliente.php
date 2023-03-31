<?php
session_start();

require_once ("../../controller/verification/functions.php");
include '../../controller/api/ws_verify_clien.php';

// echo "<br>";
// echo "<br>";

// echo "<br>";
// print_r($_SESSION['productos']);
// echo "<br>";

// echo "<br>";


// echo "<br>";

PRINT_R($_SESSION['CrePedVent']);
PRINT_R($_SESSION['UrlCamPass']);
print_r($_SESSION['login'])."<br>";


echo "<br>";
if (isset($_SESSION["DetRegla"])){
    print_r(
        $_SESSION["DetRegla"]
    );
}
print_r($_SESSION['clientes']);

echo "<br>";
if (isset($_SESSION["urlc"])){
    print_r(
        $_SESSION["urlc"]
    );
}



if (isset($_SESSION['clientes'])){
    echo "<br>"."CLIENTES"."</br>";
    print_r(
        $_SESSION['clientes']
    );
}

if (isset($_SESSION['option'])){
    echo "<br>"."option"."</br>";
    print_r(
        $_SESSION['option']
    );
}




if (isset($_SESSION['productos_obj'])){
    echo "<br>"."productos_obj"."</br>";
    print_r(
        $_SESSION['productos_obj']
    );
}


if (isset($_SESSION['UrlCartera'])){
    echo "<br>"."URL CARTERA"."</br>";
    print_r(
        $_SESSION['UrlCartera']
    );
}

if (isset($_SESSION['UrlDetPedi'])){
    echo "<br>"."URL DETALLE PEDIDO"."</br>";
    print_r(
        $_SESSION['UrlDetPedi']
    );
}

if (isset($_SESSION['UrlPedi'])){
    echo "<br>"."URL PEDIDO"."</br>";
    print_r(
        $_SESSION['UrlPedi']
    );
}

if (isset($_SESSION['UrlProductos'])){
    echo "<br>"."URL PRODUCTOS"."</br>";
    print_r(
        $_SESSION['UrlProductos']
    );
}

if (isset($_SESSION["UltConsProd"])){
    echo "<br>"."ULTIMA CONSULTA PRODUCTOS"."</br>";
    print_r(
        $_SESSION['UltConsProd']
    );
}


if (isset($_SESSION["RCruz"])){
    echo "<br>"."REFERECNIA cruzada"."</br>";
    print_r(
        $_SESSION['RCruz']
    );
}



valida_sesion();



include 'homeTop.php';



include 'homebott.php'
?>
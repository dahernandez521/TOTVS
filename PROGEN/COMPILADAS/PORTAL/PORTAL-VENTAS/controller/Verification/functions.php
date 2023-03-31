<?php

function stdToArray($obj)
{
  $reaged = (array) $obj;
  foreach ($reaged as $key => &$field) {
    if (is_object($field)) {
      $field = stdToArray($field);
    }
  }
  return $reaged;
}

function valida_sesion()
{
  if (!isset($_SESSION["login"])) {
    header("location: ../../controller/verification/logout.php");
  } else {
    $login = $_SESSION["login"];
  }
}


function valida_detail()
{
  if (isset($_SESSION["detail"])) {

    include '../../controller/api/ws_verify_produ.php';


  }


}


function valida_clien()
{
  if (!isset($_SESSION['Cliente'])) {
    header("Location: Consultar_Clientes");

  }

}

function Valida_copia()
{
  if (isset($_POST['CodPedi'])) {
    $_SESSION['CopPed'] = $_POST['CodPedi'];

    // echo "Pedido a copiar #".$_SESSION['CopPed'];
  } else {
    unset($_SESSION['CopPed']);
  }
}



function Valida_carrito()
{
  if (isset($_POST['CodCarr'])) {
    unset($_SESSION["CotizInd"]);
    $_SESSION['CodCarr'] = $_POST['CodCarr'];

    //  echo "Pedido de carrito #".$_SESSION['CodCarr'];
  }
}



function ValidaPedido()
{
  if (!isset($_POST['CodPedi'])) {
    header("Location: Consultar_pedidos");
  } else {
    $_SESSION['DetPed'] = $_POST['CodPedi'];
  }
}





?>
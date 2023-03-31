<?php


function prueba()
{
    
    session_start();
    $data = $_POST['detail'];

    unset($_SESSION['detail']);
    $_SESSION['detail']='';
    $_SESSION['detail'] = $data;
    // echo $_SESSION['detail'];
    
			

    
}



echo prueba();
?>
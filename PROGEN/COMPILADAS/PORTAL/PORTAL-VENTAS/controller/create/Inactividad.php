<?php


function prueba()
{
    session_start();
    $_SESSION['logged_time']=time();
    
		
}



echo prueba();
?>
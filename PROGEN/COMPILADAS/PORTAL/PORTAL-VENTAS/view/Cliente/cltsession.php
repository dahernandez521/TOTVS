<?php
if (session_status() == PHP_SESSION_NONE) {
    session_start();    
}

if(isset($_SESSION["logged_time"])){

    $login_session_duration = 6*10; // 1 minute 

    if($_SESSION['logged_time']){
       if(((time() - $_SESSION['logged_time']) > $login_session_duration)){ 
          echo '0';
          // session will be exired after 1 minutes
       }else{
          echo '1';
       }
    }    
} else {
    echo "0";
}
?>
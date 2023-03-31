<?php
function consulta()
{
    
    if(isset($_POST['array'])){
        $array = $_POST['array'];
    }
    

    if(isset($_GET['cod'])){
        $codigo = $_GET['cod'];      
    }
    
   session_start();
   
   if (isset($_SESSION["L_preci"])){
        $_SESSION['productos_obj']=$array["LisPreDet"];
    }else{
        $_SESSION['productos_obj']=$array["product"];
    }

    print_r($_SESSION['productos_obj']);
    
};
echo consulta();
?>
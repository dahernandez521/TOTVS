<?php
    if(isset($_POST['userportal']))
      {
          session_start();
          $_SESSION['logged_time'] = time();  // para expirar la session
          $_SESSION["HISTORICO"] = "";
          $uid = $_POST['userportal'];
          $pw = $_POST['clave'];
          $emprefilial=explode("/",$_POST['empresa']);
          if(!(isset($cambio["RESULTADO"])) AND (isset($cambio["CAMBIOPASSRESULT"])) AND $cambio["CAMBIOPASSRESULT"]=='TRUE') {
            $_SESSION['error01'] = "<div class='alert alert-success' role='alert'>Cambio de clave exitoso!!</div>";  
            unset($_SESSION['cambio']);
          }

          if((!empty(trim($uid)) and  !empty(trim($pw))))
            {   
                $_SESSION["EMPRESA"]=$emprefilial[0];
                $_SESSION["FILIAL"]=$emprefilial[1];
                $_SESSION["USERPORTAL"]=strtoupper($uid);
                $_SESSION["PASSWORD"]=$pw;

                include 'controller/api/ws_verify01.php';
                
                if (isset($_SESSION["login"] )){
                  $login=$_SESSION["login"];

                  // if( (isset($login["EXITO"]))) {
                  //   ECHO "entre la primera validación";
                  //   if($login["EXITO"]<>'0') {
                  //     ECHO "entre la segunda validación";
                  //     print_r ($login); //vaLIDACION
                  //   }
                  // }
                    // print_r ($_SESSION["login"]);
                  // echo "<script>console.log('ssa') </script>";
                  // echo "<script>console.log('ssa') </script>";
                  if( (isset($login["EXITO"])) AND $login["EXITO"]<>'0' AND $login["EXITO"]<>'69') {
                        $_SESSION['sid']=session_id();
                        $_SESSION['success'] = array("mensaje" => "HOLA! ".$login["NOME"],"nivel" =>   "2" );
                        IF ($login["EXITO"]='1') {

                          $_SESSION['CodUser']=$login['CODUSU'];
                          $_SESSION['MaiUser']=$login['EMAIL'];

                          if(strlen(trim($login['VEND']))>0){
                              $_SESSION['CodVen']=$login['VEND'];
                          }else if(strlen(trim($login['VEND']))==0){
                              $_SESSION['CodUsu']=$login['CODUSU'];
                          }

                          header("location: view/cliente/Consultar_Clientes");//cliente

                          

 
                          
                        } else {
                          header("location: index");
                        }
                    } else {
                        $_SESSION['error'] = "<div class='alert alert-danger' role='alert'>¡Upss! Datos de login incorrectos............</div>";  
                    }
                  }
            }  else {
                $_SESSION['error'] = "<div class='alert alert-danger' role='alert'>¡Upss! Datos de login incorrectos-----------</div>";
                //header("location: index.php");
            }
      } else {
        session_start();
        if( isset($_SESSION["filiales"]) and !empty($_SESSION["filiales"]) and 
            isset($_SESSION["sucursales"]) and !empty($_SESSION["sucursales"])) {
              //print_r($_SESSION["filiales"]);
              
            $filiales=$_SESSION["filiales"];
            $sucursales=$_SESSION["sucursales"];  
            $_empresa=$_SESSION["WEBWS"];  
        } else {
          $_SESSION["WEBWS"]=$_empresa;
          include 'controller/api/ws_filial01.php';
          $_SESSION["filiales"]=$filiales;
          $_SESSION["sucursales"]=$sucursales;
        }
      } 
      
?>
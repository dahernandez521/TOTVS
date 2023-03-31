<?php

require_once '../../librerias/Email/vendor/mailer/src/Exception.php';
require_once '../../librerias/Email/vendor/mailer/src/PHPMailer.php';
require_once '../../librerias/Email/vendor/mailer/src/SMTP.php';

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

$mail = new PHPMailer(true);
$mail->SMTPDebug = 0;
$mail->isSMTP();
$mail->Host = 'smtp.office365.com';
$mail->SMTPAuth = true;
$mail->Username = 'totvs@progen.com.co';
$mail->Password = 'Progen.2023';
$mail->SMTPSecure = 'tls';
$mail->Port = 587;

foreach ($_SESSION["ValMail"] as $row) {
	$_SESSION["usuPor"]=$row['CODUSU'];
	$_SESSION["nomPor"]=$row['NOME'];
	$_SESSION["maiPor"]=strtolower($row['EMAIL']);
	break;
}

$_SESSION["pasPor"]=aleatoryPassword();

$mail->From = 'totvs@progen.com.co';
$mail->FromName = 'PROGEN - TOTVS';

$mail->addAddress($_SESSION["maiPor"], $_SESSION["nomPor"]);

$mail->isHTML(true);

$mail->Subject = utf8_decode("Recuperación contraseña Portal de Ventas Progen");
$mail->Body = utf8_decode("<html> 
<head> 
<title></title> 
</head> 
<body> 
<p>Cordial Saludo, ".$_SESSION['nomPor'].".
<br>Usted ha solicitado el restablecimiento de su contraseña en el Portal de Ventas.
se le asigno la siguiente contraseña temporal:
<br><br><b>=> Usuario: ".$_SESSION['maiPor']."
<br>=> Password: ".$_SESSION["pasPor"]."

</b><br><br>Recuerde que...

<br><br>Esta contraseña es asignada por el sistema,
<br> una vez complete su ingreso se recomienda realizar el cambio

</p> 
<br>
<img src='https://static.wixstatic.com/media/c538a9_ec43143e34184572a60944bccf1fbcff~mv2.png/v1/fill/w_351,h_100,al_c,q_85,usm_0.66_1.00_0.01,enc_auto/PROGEN.png'
 width='200px'>
 
 </body> 
</html> ");
$mail->AltBody = "PORTAL VENTAS PROGEN 2023";

try {

	include '../../controller/api/ws_verify_UpdPass.php';

    $mail->send();

    echo "El mensaje ha sido enviado con éxito.";
} catch (Exception $e) {
    echo "Error al envio: " . $mail->ErrorInfo;
}




function aleatoryPassword()
	{
		//Cadena base para generar contraseña aleatoria
		$caracteres='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
		// maximo de longitud de la contraseña
		$longpalabra=8;
		// primera expresión: variable que va a contener la contraseña
		//La segunda expresión será evaluada antes de iniciar el ciclo, si su valor obtenido es TRUE el ciclo se ejecutará hasta que el valor obtenido sea FALSE.
		//La tercera expresión se ejecutará cada vez que se termine el ciclo.
		for($pass='', $n=strlen($caracteres)-1; strlen($pass) < $longpalabra ; ) {
			//obtener una posicion aleatoria de la cadena $carateres
		  $x = rand(0,$n);
		  //
		  $pass.= $caracteres[$x];
		}
		return $pass;
	}
?>
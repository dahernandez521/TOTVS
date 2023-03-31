<?php
if (session_status() == PHP_SESSION_NONE) {
    session_start();
}
function newCoti()
{
    date_default_timezone_set("America/Bogota");

    if(isset($_SESSION['CodVen'])){

        $user=$_SESSION["login"]['LOGIN'];
    }else if(isset($_SESSION['CodUsu'])){

        $user=$_SESSION["login"]['LOGIN'];
    }

    $json = $_POST['CrePedVent'];
    $Date=     date("d-m-Y h:i:s");
    $Cliente = trim($_SESSION['Cliente']);
    $tienda = $_SESSION['Loja'];

    $json = str_replace('01/01/9999',$Date,$json);
    $json = str_replace('User-999',$user,$json);
    $json = str_replace('99999999',$Cliente,$json);
    
    

    $name = '1.json';
    $rutaClien='../../Cotizaciones/' . $Cliente;
    $ruta = '../../Cotizaciones/' . $Cliente . "/" . $tienda;

    for ($i = 1; $i <= 2000; $i++) {
        if (!file_exists($ruta . "/" . $i . ".json")) {
            $name = $i . ".json";
            break;
        }


    }


    if (!file_exists($rutaClien)) {
        CreateFile(1, $ruta);
    } else {

        if (!file_exists($ruta)) {
            CreateFile(1, $ruta);
        }
    }

    if (file_exists($ruta)) {
        CreateJson($ruta, $name, $json);
    }



return "Se creo con exito la cotización #".$i;
}


function CreateFile($tipo, $name)
{

    if ($tipo == 1) {
        if (!mkdir($name, 0777, true)) {
            die('Fallo al crear la carpeta ' . $name . "<br>");
        } else {
            //  echo 'Wo ' . $name . ' creada con exito.' . "<br>";
        }


    }

}

function CreateJson($ruta, $name, $Json)
{
    $fh = fopen($ruta . "/" . $name, 'w') or die("Se produjo un error al crear el archivo " . $name);
    $texto = <<<_END
    $Json
    _END;
    fwrite($fh, $texto) or die("No se pudo crear la cotización");
    fclose($fh);
}

echo newCoti();
?>
<?php



if (!isset($row['dep'])) {
    $row['dep'] = 0;
}
if ($_SESSION['Departamento'] == $row['dep'] || $row['dep']==0) {
    if ($_SESSION['code'] == $row['code']) {

        $option .= "<option id=" . $row['code'] . " value='$row[code]' selected>" . $row['descsri'] . " - " . $row['code'] . "</option>";
    } else {
        $option .= "<option id=" . $row['code'] . " value='$row[code]'>". $row['descsri'] . " - " . $row['code'] . "</option>";
    }
}

?>
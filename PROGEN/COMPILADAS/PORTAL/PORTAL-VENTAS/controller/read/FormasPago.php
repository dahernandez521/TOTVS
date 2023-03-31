<?php
foreach ($_SESSION["Fpago"] as $row) {




    if (trim($Fpago) === (trim($row['code']))) {

        $option .= "<option id=" . $row['code'] . " value='$row[code]' selected>" . $row['name'] . " - " . $row['code'] . "</option>";


    } 
    // else {
    //      $option .= "<option id=" . $row['code'] . " value='$row[code]'>" . $row['name'] . " - " . $row['code'] . "</option>";

    // }
}
?>
<?php

function view_error()
{
    if (isset($_SESSION['error'])) {
        echo $_SESSION['error'];
        unset($_SESSION['error']);
    }

    if (isset($_SESSION['error01'])) {
        echo $_SESSION['error01'];
        unset($_SESSION['error01']);
    }

}
?>
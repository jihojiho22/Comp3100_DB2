<?php
session_start();

// Unset all session variables
$_SESSION = [];

session_destroy();

// Redirect to login page
header('Location: index.html');
exit;
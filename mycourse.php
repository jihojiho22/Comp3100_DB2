<?php
session_start();
require_once 'functions.php';

// Require login to access this page
require_login();

$servername = "localhost";
$username = "root";
$password = "";
$dbname = "DB2";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$user_id = $_SESSION['user_id'];
$user_type = $_SESSION['user_type'];
?>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>My course</h1>

</body>
</html>

<?php
// Close connection
$conn->close();
?>
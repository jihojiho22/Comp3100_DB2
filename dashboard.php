<!DOCTYPE html>
<html>
<head>
    <title>Dashboards</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>Dashboard</h1>

    <?php
    $servername = "localhost";
    $username = "root";
    $password = "";
    $dbname = "DB2";

    $conn = new mysqli($servername, $username, $password, $dbname);


    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    ?>

    <!-- Register Button (Redirect to register.php) -->
    <a href="register.php"><button type="button">Register Course</button></a>

    <!--  need implementation for modifying profile -->
    <a href="/"><button type="button">Modify profile</button></a>

</body>
</html>

<!DOCTYPE html>
<html>
<head>
    <title>Register courses</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>Register courses</h1>

    <?php

    $servername = "localhost"; 
    $username = "root";         
    $password = "";          
    $dbname = "DB2";


    $conn = new mysqli($servername, $username, $password, $dbname);


    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    $sql = "SELECT * FROM course";
    $result = $conn->query($sql);

    if ($result->num_rows > 0) {
        echo "<ul>";
        while ($row = $result->fetch_assoc()) {
            echo "<li><strong>" . $row["course_id"] . ":</strong> " . $row["course_name"] . " credit: " . $row["credits"] . " ";
            
            // Register button
            echo '<form action="register_course.php" method="post" style="display:inline;">';
            echo '<input type="hidden" name="course_id" value="' . $row["course_id"] . '">';
            echo '<button type="submit">Register</button>';
            echo '</form>';

            echo "</li>";
        }
        echo "</ul>";
    } else {
        echo "No departments found.";
    }

    // Close connection
    $conn->close();
    ?>
    <a href="dashboard.php"><button type="button">Back to Dashboard</button></a>

</body>
</html>

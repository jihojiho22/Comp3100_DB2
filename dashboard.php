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
    <h1>Dashboard</h1>
    
    <p>Welcome, <?php echo htmlspecialchars($user_id); ?></p>
    <p>Account type: <?php echo htmlspecialchars($user_type); ?></p>
    
    <!-- Register Button (displaying only for students) -->
    <?php if (!is_admin() && !is_instructor()): ?>
    <a href="register.php"><button type="button">Register Course</button></a>
    <a href="mycourse.php"><button type="button">View My Course</button></a>
    <?php endif; ?>

    <a href="modify_profile.php"><button type="button">Modify profile</button></a>
    
    <!-- Add course button (displaying only for admin) -->
    <?php if (is_admin()): ?>
    <br><br><br>
    <h3>Add New Course (Admin/Instructor Only)</h3>
    <form action="add_course.php" method="post">
        <label for="course_id">Course ID:</label>
        <input type="text" name="course_id" required><br>

        <label for="course_name">Course Name:</label>
        <input type="text" name="course_name" required><br>

        <label for="credits">Credits:</label>
        <input type="number" name="credits" required><br>

        <button type="submit">Add Course</button>
    </form>
    <?php endif; ?>

     <!-- Logout button -->
     <a href="logout.php"><button type="button">Logout</button></a>
</body>
</html>

<?php
// Close connection
$conn->close();
?>
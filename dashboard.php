<?php
session_start();
require_once 'functions.php';

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
        <a href="add_course.php"><button type ="button">Add Course</button></a>
        <a href="assign_course.php"><button type ="button">Assign Course</button></a>
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
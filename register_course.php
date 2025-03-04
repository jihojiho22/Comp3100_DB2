<?php
session_start();
require_once 'functions.php';

// Require login to access this page
require_login();

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !isset($_POST['course_id'])) {
    header('Location: register.php');
    exit;
}

$course_id = $_POST['course_id'];
$user_id = $_SESSION['user_id'];

$servername = "localhost"; 
$username = "root";         
$password = "";          
$dbname = "DB2";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Check if user already registered for this course
$check_sql = "SELECT * FROM registration WHERE user_id = ? AND course_id = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param("ss", $user_id, $course_id);
$check_stmt->execute();
$result = $check_stmt->get_result();

if ($result->num_rows > 0) {
    $_SESSION['register_message'] = "You are already registered for this course.";
} else {
    // Register the user for the course
    $insert_sql = "INSERT INTO registration (user_id, course_id) VALUES (?, ?)";
    $insert_stmt = $conn->prepare($insert_sql);
    $insert_stmt->bind_param("ss", $user_id, $course_id);
    
    if ($insert_stmt->execute()) {
        $_SESSION['register_message'] = "Successfully registered for course: " . $course_id;
    } else {
        $_SESSION['register_message'] = "Error registering for course: " . $conn->error;
    }
    
    $insert_stmt->close();
}

$check_stmt->close();
$conn->close();

header('Location: register.php');
exit;



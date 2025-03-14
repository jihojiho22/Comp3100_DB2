<?php
session_start();
require_once 'functions.php';

// Require login to access this page
require_login();

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: dashboard.php');
    exit;
}

$conn = get_db_connection();

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$course_id = $_POST['course_id'];
$course_name = $_POST['course_name'];
$credits = $_POST['credits'];

$sql = "INSERT INTO course (course_id, course_name, credits) VALUES (?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("ssi", $course_id, $course_name, $credits);

if ($stmt->execute()) {
    echo "New course added successfully!";
    echo "<br><a href='dashboard.php'>Go back to Dashboard</a>"; 
} else {
    echo "Error: " . $stmt->error;
    echo "<br><a href='dashboard.php'>Go back to Dashboard</a>";
}

$stmt->close();
$conn->close();
?>
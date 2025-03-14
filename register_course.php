<?php
session_start();
require_once 'functions.php';

require_login();

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || 
    !isset($_POST['course_id']) || 
    !isset($_POST['section_id']) || 
    !isset($_POST['semester']) || 
    !isset($_POST['year'])) {
    header('Location: register.php');
    exit;
}

$conn = get_db_connection();

$user_id = $_SESSION['user_id'];
$user_type = $_SESSION['user_type'];

// Fetch the student_id for the current user if the user type is 'student'
$student_id = null;
if ($user_type === 'student') {
    $student_id = get_student_id($user_id, $conn);
}

if (!$student_id) {
    die("Error: Student ID not found.");
}

// Get posted values
$course_id = $_POST['course_id'];
$section_id = $_POST['section_id'];
$semester = $_POST['semester'];
$year = $_POST['year'];

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Check if student is already registered for this course section
$check_sql = "SELECT * FROM take 
              WHERE student_id = ? 
              AND course_id = ? 
              AND section_id = ? 
              AND semester = ? 
              AND year = ?";
$check_stmt = $conn->prepare($check_sql);
$check_stmt->bind_param("ssssi", $student_id, $course_id, $section_id, $semester, $year);
$check_stmt->execute();
$check_result = $check_stmt->get_result();

if ($check_result->num_rows > 0) {
    $_SESSION['register_message'] = "You are already registered for this course section.";
} else {
    // Insert into take table
    $insert_sql = "INSERT INTO take (student_id, course_id, section_id, semester, year, grade) 
                   VALUES (?, ?, ?, ?, ?, NULL)";
    $insert_stmt = $conn->prepare($insert_sql);
    $insert_stmt->bind_param("ssssi", $student_id, $course_id, $section_id, $semester, $year);

    if ($insert_stmt->execute()) {
        $_SESSION['register_message'] = "Successfully registered for course: " . htmlspecialchars($course_id);
    } else {
        $_SESSION['register_message'] = "Error registering for course: " . $conn->error;
    }
    $insert_stmt->close();
}

$check_stmt->close();
$conn->close();

header('Location: register.php');
exit;

<?php
session_start();
require_once 'functions.php';

require_login();

if ($_SERVER['REQUEST_METHOD'] !== 'POST' || !isset($_POST['course_id'])) {
    header('Location: register.php');
    exit;
}

$course_id = $_POST['course_id'];
$student_id = $_SESSION['user_id'];
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "DB2";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$section_sql = "SELECT course_id, section_id, semester, year 
                FROM section 
                WHERE course_id = ? 
                ORDER BY year DESC, semester 
                LIMIT 1";
$section_stmt = $conn->prepare($section_sql);
$section_stmt->bind_param("s", $course_id);
$section_stmt->execute();
$section_result = $section_stmt->get_result();

if ($section_result->num_rows > 0) {
    $section_row = $section_result->fetch_assoc();
    
    // Check if student is already registered for this section
    $check_sql = "SELECT * FROM take 
                  WHERE student_id = ? 
                  AND course_id = ? 
                  AND section_id = ? 
                  AND semester = ? 
                  AND year = ?";
    $check_stmt = $conn->prepare($check_sql);
    $check_stmt->bind_param("ssssi", 
        $student_id, 
        $section_row['course_id'], 
        $section_row['section_id'], 
        $section_row['semester'], 
        $section_row['year']
    );
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();

    if ($check_result->num_rows > 0) {
        $_SESSION['register_message'] = "You are already registered for this course.";
    } else {
        // Insert into take table
        $insert_sql = "INSERT INTO take (student_id, course_id, section_id, semester, year) 
                       VALUES (?, ?, ?, ?, ?)";
        $insert_stmt = $conn->prepare($insert_sql);
        $insert_stmt->bind_param("ssssi", 
            $student_id, 
            $section_row['course_id'], 
            $section_row['section_id'], 
            $section_row['semester'], 
            $section_row['year']
        );

        if ($insert_stmt->execute()) {
            $_SESSION['register_message'] = "Successfully registered for course: " . $course_id;
        } else {
            $_SESSION['register_message'] = "Error registering for course: " . $conn->error;
        }
        $insert_stmt->close();
    }
    $check_stmt->close();
} else {
    $_SESSION['register_message'] = "No available sections for this course.";
}

$section_stmt->close();
$conn->close();

header('Location: register.php');
exit;
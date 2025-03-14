<?php
session_start();
require_once 'functions.php';

$conn = get_db_connection();

if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $course_id = trim($_POST['course_id']);
    $section_id = trim($_POST['section_id']);
    $semester = trim($_POST['semester']);
    $year = trim($_POST['year']);
    $instructor_id = trim($_POST['instructor_id']);
    $time_slot_id = trim($_POST['time_slot_id']);
    $classroom_id = trim($_POST['classroom_id']);

    // Validate inputs
    if (empty($course_id) || empty($section_id) || empty($semester) || empty($year) || empty($instructor_id) || empty($time_slot_id) || empty($classroom_id)) {
        $_SESSION['error_message'] = "All fields are required.";
        header("Location: assign_course.php");
        exit();
    }

    // Check if the time slot already has two sections
    $check_time_slot = "SELECT COUNT(*) AS count FROM section WHERE time_slot_id = ? AND semester = ? AND year = ?";
    $stmt = $conn->prepare($check_time_slot);
    if (!$stmt) {
        die("SQL Error: " . $conn->error);
    }
    $stmt->bind_param("sss", $time_slot_id, $semester, $year);
    $stmt->execute();
    $result = $stmt->get_result()->fetch_assoc();
    
    if ($result['count'] >= 2) {
        $_SESSION['error_message'] = "This time slot already has two sections scheduled.";
        header("Location: assign_course.php");
        exit();
    }

    // Check if the instructor is already teaching two sections
    $check_instructor = "SELECT COUNT(*) AS count FROM section WHERE instructor_id = ? AND semester = ? AND year = ?";
    $stmt = $conn->prepare($check_instructor);
    if (!$stmt) {
        die("SQL Error: " . $conn->error);
    }
    $stmt->bind_param("sss", $instructor_id, $semester, $year);
    $stmt->execute();
    $result = $stmt->get_result()->fetch_assoc();
    
    if ($result['count'] >= 2) {
        $_SESSION['error_message'] = "This instructor is already teaching two sections.";
        header("Location: assign_course.php");
        exit();
    }

    // Insert new section
    $insert_section = "INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($insert_section);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }
    $stmt->bind_param("sssssss", $course_id, $section_id, $semester, $year, $instructor_id, $classroom_id, $time_slot_id);

    if ($stmt->execute()) {
        $_SESSION['success_message'] = "Course section successfully created!";
    } else {
        $_SESSION['error_message'] = "Error inserting data: " . $stmt->error;
    }

    // Redirect to previous page
    header("Location: assign_course.php");
    exit();
}
?>

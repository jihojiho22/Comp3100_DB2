<?php
session_start();
require_once 'config&functions.php';

// Require login to access this page
require_login();

$conn = get_db_connection();

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$user_id = $_SESSION['user_id'];
$user_type = $_SESSION['user_type'];

if ($user_type !== 'student') {
    echo "Only students can access this page.";
    exit;
}

// Fetch student ID for the logged-in user
$student_id = get_student_id($user_id, $conn);
if (!$student_id) {
    die("Error: Student ID not found.");
}

// Drop course
if ($_SERVER['REQUEST_METHOD'] === 'POST' && 
    isset($_POST['course_id'], $_POST['section_id'], $_POST['semester'], $_POST['year'])) {

    $course_id = $_POST['course_id'];
    $section_id = $_POST['section_id'];
    $semester = $_POST['semester'];
    $year = $_POST['year'];

    // Check if not registered
    $check_sql = "SELECT * FROM take WHERE student_id = ? AND course_id = ? AND section_id = ? AND semester = ? AND year = ?";
    $check_stmt = $conn->prepare($check_sql);
    $check_stmt->bind_param("ssssi", $student_id, $course_id, $section_id, $semester, $year);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();

    if ($check_result->num_rows <= 0) {
        $_SESSION['register_message'] = "You are not registered for this course section.";
    } else {
        // Delete student
        $delete_sql = "DELETE FROM take WHERE student_id = ? AND course_id = ? AND section_id = ? AND semester = ? AND year = ?";
        $delete_stmt = $conn->prepare($delete_sql);
        $delete_stmt->bind_param("ssssi", $student_id, $course_id, $section_id, $semester, $year);

        if ($delete_stmt->execute()) {
            $_SESSION['register_message'] = "Successfully dropped course: " . htmlspecialchars($course_id);
        } else {
            $_SESSION['register_message'] = "Error dropping course: " . $conn->error;
        }
        $delete_stmt->close();
    }

    $check_stmt->close();
}

// Fetch registered courses
$sql = "SELECT t.course_id, t.section_id, t.semester, t.year, t.grade, 
               c.course_name, c.credits
        FROM take t
        JOIN course c ON t.course_id = c.course_id
        WHERE t.student_id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $student_id);
$stmt->execute();
$result = $stmt->get_result();
?>


<!DOCTYPE html>
<html>
<head>
    <title>Drop Courses</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>Drop Course Sections</h1>

    <?php if (isset($_SESSION['register_message'])): ?>
        <p style="color: red;">
            <?php 
                echo $_SESSION['register_message']; 
                unset($_SESSION['register_message']);
            ?>
        </p>
    <?php endif; ?>

    <?php
    if ($result->num_rows > 0) {
        echo "<ul>";
        while ($row = $result->fetch_assoc()) {
            $course_section_key = $row["course_id"] . "_" . $row["section_id"];
            $is_registered = isset($registered_courses[$course_section_key]);

            echo "<li><strong>Course ID:</strong> " . htmlspecialchars($row["course_id"]) . 
                 " - <strong>Section:</strong> " . htmlspecialchars($row["section_id"]) . 
                 " - <strong>Course Name:</strong> " . htmlspecialchars($row["course_name"]) . 
                 " - <strong>Semester:</strong> " . htmlspecialchars($row["semester"]) . 
                 " - <strong>Year:</strong> " . htmlspecialchars($row["year"]) . 
                 " - <strong>Credits:</strong> " . htmlspecialchars($row["credits"]);

            if ($is_registered) {
                echo " <span style='color: red;'>✔ Already Dropped</span>";
            } else {
                echo '<form method="post" style="display:inline;">';
                echo '<input type="hidden" name="course_id" value="' . htmlspecialchars($row["course_id"]) . '">';
                echo '<input type="hidden" name="section_id" value="' . htmlspecialchars($row["section_id"]) . '">';
                echo '<input type="hidden" name="semester" value="' . htmlspecialchars($row["semester"]) . '">';
                echo '<input type="hidden" name="year" value="' . htmlspecialchars($row["year"]) . '">';
                echo '<button type="submit">Drop</button>';
                echo '</form>';
            }

            echo "</li>";
        }
        echo "</ul>";
    } else {
        echo "Not regestered for any courses.";
    }

    $conn->close();
    ?>

    <a href="student.php?page=home"><button type="button">Back to Dashboard</button></a>
</body>
</html>

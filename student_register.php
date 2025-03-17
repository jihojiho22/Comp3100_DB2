<?php
session_start();
require_once 'config&functions.php';

$conn = get_db_connection();

require_login();

// Fetch student ID
$user_id = $_SESSION['user_id'];
$user_type = $_SESSION['user_type'];
$student_id = ($user_type === 'student') ? get_student_id($user_id, $conn) : null;
$current_semester = "Fall";
$current_year = 2023;

if (!$student_id) {
    die("Error: Student ID not found.");
}

//  Course registration
if ($_SERVER['REQUEST_METHOD'] === 'POST' && 
    isset($_POST['course_id'], $_POST['section_id'], $_POST['semester'], $_POST['year'])) {

    $course_id = $_POST['course_id'];
    $section_id = $_POST['section_id'];
    $semester = $_POST['semester'];
    $year = $_POST['year'];

    // Check if already registered
    $check_sql = "SELECT * FROM take WHERE student_id = ? AND course_id = ? AND section_id = ? AND semester = ? AND year = ?";
    $check_stmt = $conn->prepare($check_sql);
    $check_stmt->bind_param("ssssi", $student_id, $course_id, $section_id, $semester, $year);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();

    if ($check_result->num_rows > 0) {
        $_SESSION['register_message'] = "You are already registered for this course section.";
    } else {
        // Register student
        $insert_sql = "INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES (?, ?, ?, ?, ?, NULL)";
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
}

// Fetch registered courses
$registered_courses = [];
$reg_sql = "SELECT course_id, section_id FROM take WHERE student_id = ?";
$reg_stmt = $conn->prepare($reg_sql);
$reg_stmt->bind_param("s", $student_id);
$reg_stmt->execute();
$reg_result = $reg_stmt->get_result();

while ($row = $reg_result->fetch_assoc()) {
    $registered_courses[$row["course_id"] . "_" . $row["section_id"]] = true;
}
$reg_stmt->close();

// Fetch available courses
$sql = "SELECT s.*, c.course_name, c.credits FROM section s JOIN course c ON s.course_id = c.course_id";
$result = $conn->query($sql);

?>

<!DOCTYPE html>
<html>
<head>
    <title>Register Courses</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>Register for Course Sections</h1>
    <h2>Current Semester</h2>
    <h3><?php echo htmlspecialchars($current_semester); ?> <?php echo htmlspecialchars($current_year); ?></h3>

    <?php if (isset($_SESSION['register_message'])): ?>
        <p style="color: green;">
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

            if($row["semester"] == $current_semester && $row["year"] == $current_year) {

                echo "<li><strong>Course ID:</strong> " . htmlspecialchars($row["course_id"]) . 
                " - <strong>Section:</strong> " . htmlspecialchars($row["section_id"]) . 
                " - <strong>Course Name:</strong> " . htmlspecialchars($row["course_name"]) . 
                " - <strong>Semester:</strong> " . htmlspecialchars($row["semester"]) . 
                " - <strong>Year:</strong> " . htmlspecialchars($row["year"]) . 
                " - <strong>Credits:</strong> " . htmlspecialchars($row["credits"]);


            if ($is_registered) {
                echo " <span style='color: green;'>✔ Already Registered</span>";
            } else {
                echo '<form method="post" style="display:inline;">';
                echo '<input type="hidden" name="course_id" value="' . htmlspecialchars($row["course_id"]) . '">';
                echo '<input type="hidden" name="section_id" value="' . htmlspecialchars($row["section_id"]) . '">';
                echo '<input type="hidden" name="semester" value="' . htmlspecialchars($row["semester"]) . '">';
                echo '<input type="hidden" name="year" value="' . htmlspecialchars($row["year"]) . '">';
                echo '<button type="submit">Register</button>';
                echo '</form>';
            }
            }



            echo "</li>";
        }
        echo "</ul>";
    } else {
        echo "No available courses found.";
    }

    $conn->close();
    ?>

    <a href="student.php?page=home"><button type="button">Back to Dashboard</button></a>
</body>
</html>

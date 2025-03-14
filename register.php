<?php
session_start();
require_once 'functions.php';

$conn = get_db_connection();
?>

<!DOCTYPE html>
<html>
<head>
    <title>Register Courses</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>Register for Course Sections</h1>

    <!-- Show registration message if available -->
    <?php if (isset($_SESSION['register_message'])): ?>
        <p style="color: green; font-weight: bold;">
            <?php 
                echo $_SESSION['register_message']; 
                unset($_SESSION['register_message']);
            ?>
        </p>
    <?php endif; ?>

    <?php
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }

    // Fetch student ID
    $user_id = $_SESSION['user_id'];
    $user_type = $_SESSION['user_type'];
    $student_id = ($user_type === 'student') ? get_student_id($user_id, $conn) : null;

    // Fetch registered courses
    $registered_courses = [];
    if ($student_id) {
        $reg_sql = "SELECT course_id, section_id FROM take WHERE student_id = ?";
        $reg_stmt = $conn->prepare($reg_sql);
        $reg_stmt->bind_param("s", $student_id);
        $reg_stmt->execute();
        $reg_result = $reg_stmt->get_result();

        while ($row = $reg_result->fetch_assoc()) {
            $registered_courses[$row["course_id"] . "_" . $row["section_id"]] = true;
        }
        $reg_stmt->close();
    }

    // Fetch available courses
    $sql = "SELECT s.*, c.course_name, c.credits
            FROM section s
            JOIN course c ON s.course_id = c.course_id";
    $result = $conn->query($sql);

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
                echo " <span style='color: green;'>✔ Already Registered</span>";
            } else {
                echo '<form action="register_course.php" method="post" style="display:inline;">';
                echo '<input type="hidden" name="course_id" value="' . htmlspecialchars($row["course_id"]) . '">';
                echo '<input type="hidden" name="section_id" value="' . htmlspecialchars($row["section_id"]) . '">';
                echo '<input type="hidden" name="semester" value="' . htmlspecialchars($row["semester"]) . '">';
                echo '<input type="hidden" name="year" value="' . htmlspecialchars($row["year"]) . '">';
                echo '<button type="submit">Register</button>';
                echo '</form>';
            }

            echo "</li>";
        }
        echo "</ul>";
    } else {
        echo "No available courses found.";
    }

    $conn->close();
    ?>

    <a href="dashboard.php"><button type="button">Back to Dashboard</button></a>
</body>
</html>

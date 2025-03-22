<?php
session_start();
require_once 'config&functions.php';

$conn = get_db_connection();
require_login();

// Fetch student ID
$user_id = $_SESSION['user_id'];
$user_type = $_SESSION['user_type'];
$student_id = ($user_type === 'student') ? get_student_id($user_id, $conn) : null;
$current_semester = "Spring";
$current_year = 2024;

if (!$student_id) {
    die("Error: Student ID not found.");
}

// Course registration
if ($_SERVER['REQUEST_METHOD'] === 'POST' && 
    isset($_POST['course_id'], $_POST['section_id'], $_POST['semester'], $_POST['year'])) {

    $course_id = $_POST['course_id'];
    $section_id = $_POST['section_id'];
    $semester = $_POST['semester'];
    $year = $_POST['year'];

    // Check if already registered
    $check_sql = "SELECT 1 FROM take WHERE student_id = ? AND course_id = ? AND section_id = ? AND semester = ? AND year = ?";
    $check_stmt = $conn->prepare($check_sql);
    $check_stmt->bind_param("ssssi", $student_id, $course_id, $section_id, $semester, $year);
    $check_stmt->execute();
    $check_result = $check_stmt->get_result();

    if ($check_result->num_rows > 0) {
        $_SESSION['register_message'] = "You are already registered for this course section.";
    } else {
        // Check prerequisites
        $prereq_sql = "SELECT prereq_id FROM prereq WHERE course_id = ?";
        $prereq_stmt = $conn->prepare($prereq_sql);
        $prereq_stmt->bind_param("s", $course_id);
        $prereq_stmt->execute();
        $prereq_result = $prereq_stmt->get_result();

        $prereq_met = true;

        while ($prereq = $prereq_result->fetch_assoc()) {
            $prereq_id = $prereq['prereq_id'];

            // Check if student has passed the prerequisite
            $check_prereq_sql = "SELECT 1 FROM take WHERE student_id = ? AND course_id = ? AND grade IS NOT NULL AND grade <> 'F'";
            $check_prereq_stmt = $conn->prepare($check_prereq_sql);
            $check_prereq_stmt->bind_param("ss", $student_id, $prereq_id);
            $check_prereq_stmt->execute();
            $prereq_taken = $check_prereq_stmt->get_result();

            if ($prereq_taken->num_rows === 0) {
                $prereq_met = false;
                break;
            }
        }

        if (!$prereq_met) {
            $_SESSION['register_message'] = "You cannot register for $course_id because you have not completed the required prerequisites.";
        } else {
            // Register course section
            $insert_sql = "INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES (?, ?, ?, ?, ?, NULL)";
            $insert_stmt = $conn->prepare($insert_sql);
            $insert_stmt->bind_param("ssssi", $student_id, $course_id, $section_id, $semester, $year);

            if ($insert_stmt->execute()) {
                $_SESSION['register_message'] = "Successfully registered for course: " . htmlspecialchars($course_id);
            } else {
                $_SESSION['register_message'] = "An error occurred. Please try again later.";
                error_log("SQL Error: " . $conn->error);
            }
            $insert_stmt->close();
        }
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
$sql = "SELECT s.*, c.course_name, c.credits, r.capacity, 
        (SELECT COUNT(*) FROM take t WHERE t.course_id = s.course_id AND t.section_id = s.section_id AND t.semester = s.semester AND t.year = s.year) AS enrolled_count 
        FROM section s 
        JOIN course c ON s.course_id = c.course_id 
        JOIN classroom r ON s.classroom_id = r.classroom_id";
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
    <h3><?php echo htmlspecialchars($current_semester) . " " . htmlspecialchars($current_year); ?></h3>

    <?php if (isset($_SESSION['register_message'])): ?>
        <p style="color: green;">
            <?php 
                echo $_SESSION['register_message']; 
                unset($_SESSION['register_message']);
            ?>
        </p>
    <?php endif; ?>

    <?php if ($result->num_rows > 0): ?>
        <ul>
            <?php while ($row = $result->fetch_assoc()): 
                $course_section_key = $row["course_id"] . "_" . $row["section_id"];
                $is_registered = isset($registered_courses[$course_section_key]);

                if ($row["semester"] == $current_semester && $row["year"] == $current_year): ?>
                    <li>
                        <strong>Course ID:</strong> <?php echo htmlspecialchars($row["course_id"]); ?> -
                        <strong>Section:</strong> <?php echo htmlspecialchars($row["section_id"]); ?> -
                        <strong>Course Name:</strong> <?php echo htmlspecialchars($row["course_name"]); ?> -
                        <strong>Semester:</strong> <?php echo htmlspecialchars($row["semester"]); ?> -
                        <strong>Year:</strong> <?php echo htmlspecialchars($row["year"]); ?> -
                        <strong>Credits:</strong> <?php echo htmlspecialchars($row["credits"]); ?> -
                        <strong>Capacity:</strong> <?php echo htmlspecialchars($row["enrolled_count"]); ?> / <?php echo htmlspecialchars($row["capacity"]); ?>
                

                        <?php if ($is_registered): ?>
                            <span style='color: green;'>✔ Already Registered</span>
                        <?php else: ?>
                            <form method="post" style="display:inline;">
                                <input type="hidden" name="course_id" value="<?php echo htmlspecialchars($row["course_id"]); ?>">
                                <input type="hidden" name="section_id" value="<?php echo htmlspecialchars($row["section_id"]); ?>">
                                <input type="hidden" name="semester" value="<?php echo htmlspecialchars($row["semester"]); ?>">
                                <input type="hidden" name="year" value="<?php echo htmlspecialchars($row["year"]); ?>">
                                <button type="submit" <?php if ($row["enrolled_count"] >= $row["capacity"]) echo 'disabled'; ?>>Register</button>
                            </form>
                        <?php endif; ?>
                    </li>
                <?php endif; ?>
            <?php endwhile; ?>
        </ul>
    <?php else: ?>
        <p>No available courses found.</p>
    <?php endif; ?>

    <a href="student.php?page=home"><button type="button">Back to Dashboard</button></a>
</body>
</html>

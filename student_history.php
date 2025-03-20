<?php
session_start();
require_once 'config&functions.php';

// Require login to access this page
require_login();

$conn = get_db_connection();
$page = isset($_GET['page']) ? $_GET['page'] : null;

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$user_id = $_SESSION['user_id'];
$user_type = $_SESSION['user_type'];

// if ($user_type !== 'student') {
//     echo "Only students can access this page.";
//     exit;
// }

// // Fetch student ID for the logged-in user
$student_id = get_student_id($user_id, $conn);
$instructor_id = get_instructor_id($user_id, $conn);
// if (!$student_id) {
//     die("Error: Student ID not found.");
// }

// Fetch registered courses
$sql = "SELECT t.course_id, t.section_id, t.semester, t.year, t.grade, 
               c.course_name, c.credits
        FROM take t
        JOIN course c ON t.course_id = c.course_id
        WHERE t.student_id = ?
        ORDER BY t.year DESC, 
                 FIELD(t.semester, 'Summer', 'Spring', 'Winter', 'Fall')";

$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $student_id);
$stmt->execute();
$result = $stmt->get_result();

// course ID for instructor course records.
$sql_courseID = "SELECT course_id, section_id, semester, year FROM section WHERE instructor_id = ?";
$stmt_courseID = $conn->prepare($sql_courseID);
$stmt_courseID->bind_param("i", $instructor_id);
$stmt_courseID->execute();
$result_courseID = $stmt_courseID->get_result();


?>

<!DOCTYPE html>
<html>
<head>
    <title>My Courses</title>
    <meta charset="UTF-8">
</head>
<body>
<!-- only accessbile to student -->
    <?php if ($page === "my_courses"): ?>
        <h1>My Courses</h1>

<?php if ($result->num_rows > 0): ?>
    <table>
        <tr>
            <th>Course ID</th>
            <th>Course Name</th>
            <th>Section ID</th>
            <th>Semester</th>
            <th>Year</th>
            <th>Credits</th>
            <th>Grade</th>
        </tr>
        <?php while ($row = $result->fetch_assoc()): ?>
            <tr>
                <td><?= htmlspecialchars($row['course_id']) ?></td>
                <td><?= htmlspecialchars($row['course_name']) ?></td>
                <td><?= htmlspecialchars($row['section_id']) ?></td>
                <td><?= htmlspecialchars($row['semester']) ?></td>
                <td><?= htmlspecialchars($row['year']) ?></td>
                <td><?= htmlspecialchars($row['credits']) ?></td>
                <td><?= $row['grade'] ? htmlspecialchars($row['grade']) : 'N/A' ?></td>
            </tr>
        <?php endwhile; ?>
    </table>
<?php else: ?>
    <p>You are not enrolled in any courses.</p>
<?php endif; ?>

<a href="student.php?page=home"><button type="button">Back to Dashboard</button></a>
    <?php endif; ?>
    

<!-- only accessbile to instructor -->
<?php if ($page === "course_records"): ?>
    <h1>Course Records</h1>
    <?php 
    if ($result_courseID->num_rows > 0) {
        while ($row = $result_courseID->fetch_assoc()) {
            echo '<h2>Course: ' . htmlspecialchars($row['course_id']) . '</h2>';
            echo '<h3>Section: ' . htmlspecialchars($row['section_id']) . ' - ' .
                 htmlspecialchars($row['semester']) . ' ' . htmlspecialchars($row['year']) . '</h3>';
    
            // enrolled students for this section
            $sql_enrolled = "SELECT s.name 
                FROM take t 
                JOIN student s ON t.student_id = s.student_id 
                WHERE t.course_id = ? 
                AND t.section_id = ? 
                AND t.semester = ? 
                AND t.year = ?";
            $stmt_enrolled = $conn->prepare($sql_enrolled);
            $stmt_enrolled->bind_param("sssi", $row['course_id'], $row['section_id'], $row['semester'], $row['year']);
            $stmt_enrolled->execute();
            $result_enrolled = $stmt_enrolled->get_result();
    
            echo "<ul>";
            if ($result_enrolled->num_rows > 0) {
                while ($enrolled = $result_enrolled->fetch_assoc()) {
                    echo "<li>" . htmlspecialchars($enrolled['name']) . "</li>";
                }
            } else {
                echo "<li>No students enrolled.</li>";
            }
            echo "</ul>";
            $stmt_enrolled->close();
        }
    } else {
        echo '<h2>No course records found.</h2>';
    }
    ?>
    <a href="student.php?page=home"><button>Back To Dashboard</button></a>
<?php endif; ?>

</body>
</html>

<?php
// Close connection
$stmt->close();
$conn->close();
?>

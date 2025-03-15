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
    <title>My Courses</title>
    <meta charset="UTF-8">
</head>
<body>
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
</body>
</html>

<?php
// Close connection
$stmt->close();
$conn->close();
?>

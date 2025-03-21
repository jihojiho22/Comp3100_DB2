<?php
session_start();
require_once 'config&functions.php';

require_login();

$conn = get_db_connection();
$page = isset($_GET['page']) ? $_GET['page'] : null;

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$user_id = $_SESSION['user_id'];
$user_type = $_SESSION['user_type'];

// Fetch student ID for the logged-in user
$student_id = get_student_id($user_id, $conn);

// Fetch registered courses with instructor name
$sql = "SELECT t.course_id, t.section_id, t.semester, t.year, t.grade, 
               c.course_name, c.credits, s.instructor_id, i.instructor_name
        FROM take t
        JOIN course c ON t.course_id = c.course_id
        LEFT JOIN section s ON t.course_id = s.course_id 
                           AND t.section_id = s.section_id 
                           AND t.semester = s.semester 
                           AND t.year = s.year
        LEFT JOIN instructor i ON s.instructor_id = i.instructor_id
        WHERE t.student_id = ?
        ORDER BY t.year DESC, 
                 FIELD(t.semester, 'Summer', 'Spring', 'Winter', 'Fall')";

$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $student_id);
$stmt->execute();
$result = $stmt->get_result();

// Handle form submission for rating
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['submit_rating'])) {
    $instructor_id = $_POST['instructor_id'];
    $course_id = $_POST['course_id'];
    $section_id = $_POST['section_id'];
    $rating = $_POST['rating'];

    // Check if the student has already rated the instructor for this course and section
    $sql_check_rating = "SELECT * FROM instructor_rating WHERE instructor_id = ? AND student_id = ? AND section_id = ? AND course_id = ?";
    $stmt_check_rating = $conn->prepare($sql_check_rating);
    $stmt_check_rating->bind_param("ssss", $instructor_id, $student_id, $section_id, $course_id);
    $stmt_check_rating->execute();
    $check_result = $stmt_check_rating->get_result();

    if ($check_result->num_rows > 0) {
        $message = "already rated this instructor!";
    } else {
        // Insert the rating into the instructor_rating table
        $sql_insert_rating = "INSERT INTO instructor_rating (instructor_id, rating, student_id, section_id, course_id) 
                              VALUES (?, ?, ?, ?, ?)";
        $stmt_rating = $conn->prepare($sql_insert_rating);
        $stmt_rating->bind_param("siiss", $instructor_id, $rating, $student_id, $section_id, $course_id);
        
        if ($stmt_rating->execute()) {
            $message = "Thank you for rating the instructor!";
        } else {
            $message = "Error submitting your rating. Please try again later.";
        }
        $stmt_rating->close();
    }

    $stmt_check_rating->close();
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>My Courses</title>
    <meta charset="UTF-8">
</head>
<body>

<h1>My Courses</h1>

<?php if (isset($message)): ?>
    <p><?= $message ?></p>
<?php endif; ?>

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
            <th>Instructor</th>
            <th>Rate Instructor</th>
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
                <td><?= htmlspecialchars($row['instructor_name']) ?></td>
                <td>
                    <?php if (!empty($row['grade']) && !empty($row['instructor_name'])): ?>
                        <!-- Check if the student already rated the instructor -->
                        <?php
                        $instructor_id = $row['instructor_id'];
                        $course_id = $row['course_id'];
                        $section_id = $row['section_id'];

                        // Check if this student has already rated the instructor
                        $sql_check_rating = "SELECT * FROM instructor_rating WHERE instructor_id = ? AND student_id = ? AND section_id = ? AND course_id = ?";
                        $stmt_check_rating = $conn->prepare($sql_check_rating);
                        $stmt_check_rating->bind_param("ssss", $instructor_id, $student_id, $section_id, $course_id);
                        $stmt_check_rating->execute();
                        $check_result = $stmt_check_rating->get_result();
                        ?>
                        <?php if ($check_result->num_rows > 0): ?>
                            <!-- Rating already exists -->
                            <p>Done!</p>
                        <?php else: ?>
                            <!-- Rating Form -->
                            <form method="POST" action="">
                                <input type="hidden" name="instructor_id" value="<?= htmlspecialchars($row['instructor_id']) ?>">
                                <input type="hidden" name="course_id" value="<?= htmlspecialchars($row['course_id']) ?>">
                                <input type="hidden" name="section_id" value="<?= htmlspecialchars($row['section_id']) ?>">
                                <input type="number" id="rating" name="rating" min="1" max="5" required>
                                <button type="submit" name="submit_rating" >Rate</button>
                            </form>
                        <?php endif; ?>
                    <?php endif; ?>
                </td>
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
$stmt->close();
$conn->close();
?>

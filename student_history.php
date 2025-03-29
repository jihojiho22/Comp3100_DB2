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

if ($page === 'course_records' && $user_type === 'instructor') {
    // Handle grade submission
    if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['submit_grade'])) {
        $student_id = $_POST['student_id'];
        $course_id = $_POST['course_id'];
        $section_id = $_POST['section_id'];
        $semester = $_POST['semester'];
        $year = $_POST['year'];
        $grade = $_POST['grade'];

        $update_sql = "UPDATE take SET grade = ? 
                      WHERE student_id = ? AND course_id = ? AND section_id = ? 
                      AND semester = ? AND year = ?";
        $update_stmt = $conn->prepare($update_sql);
        $update_stmt->bind_param("ssssss", $grade, $student_id, $course_id, $section_id, $semester, $year);
        
        if ($update_stmt->execute()) {
            $message = "Grade updated successfully!";
        } else {
            $message = "Error updating grade.";
        }
        $update_stmt->close();
    }

    // Get instructor ID
    $instructor_id = get_instructor_id($user_id, $conn);

    // Fetch sections taught by this instructor with student info
    $sql = "SELECT s.course_id, s.section_id, s.semester, s.year, 
                   c.course_name, c.credits,
                   t.student_id, t.grade,
                   st.name as student_name
            FROM section s
            JOIN course c ON s.course_id = c.course_id
            LEFT JOIN take t ON s.course_id = t.course_id 
                           AND s.section_id = t.section_id
                           AND s.semester = t.semester
                           AND s.year = t.year
            LEFT JOIN student st ON t.student_id = st.student_id
            WHERE s.instructor_id = ?
            ORDER BY s.year DESC, 
                     FIELD(s.semester, 'Summer', 'Spring', 'Winter', 'Fall'),
                     s.course_id, s.section_id, st.name";

    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $instructor_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $sections = [];
    while ($row = $result->fetch_assoc()) {
        $key = $row['course_id'] . '_' . $row['section_id'] . '_' . $row['semester'] . '_' . $row['year'];
        if (!isset($sections[$key])) {
            $sections[$key] = [
                'course_id' => $row['course_id'],
                'course_name' => $row['course_name'],
                'section_id' => $row['section_id'],
                'semester' => $row['semester'],
                'year' => $row['year'],
                'credits' => $row['credits'],
                'students' => []
            ];
        }
        if ($row['student_id']) {
            $sections[$key]['students'][] = [
                'student_id' => $row['student_id'],
                'student_name' => $row['student_name'],
                'grade' => $row['grade']
            ];
        }
    }
    ?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>Course Records</title>
        <meta charset="UTF-8">
    </head>
    <body>
        <h1>Course Records</h1>

        <?php if (isset($message)): ?>
            <p><?= $message ?></p>
        <?php endif; ?>

        <?php if (!empty($sections)): ?>
            <?php foreach ($sections as $section): ?>
                <div>
                    <h2><?= htmlspecialchars($section['course_id']) ?> - <?= htmlspecialchars($section['course_name']) ?></h2>
                    <p>Section: <?= htmlspecialchars($section['section_id']) ?></p>
                    <p>Semester: <?= htmlspecialchars($section['semester']) ?> <?= htmlspecialchars($section['year']) ?></p>
                </div>
                
                <?php if (!empty($section['students'])): ?>
                    <table>
                        <tr>
                            <th>Student ID</th>
                            <th>Student Name</th>
                            <th>Grade</th>
                            <th>Action</th>
                        </tr>
                        <?php foreach ($section['students'] as $student): ?>
                            <tr>
                                <td><?= htmlspecialchars($student['student_id']) ?></td>
                                <td><?= htmlspecialchars($student['student_name']) ?></td>
                                <td><?= $student['grade'] ? htmlspecialchars($student['grade']) : 'N/A' ?></td>
                                <td>
                                    <form method="POST">
                                        <input type="hidden" name="student_id" value="<?= htmlspecialchars($student['student_id']) ?>">
                                        <input type="hidden" name="course_id" value="<?= htmlspecialchars($section['course_id']) ?>">
                                        <input type="hidden" name="section_id" value="<?= htmlspecialchars($section['section_id']) ?>">
                                        <input type="hidden" name="semester" value="<?= htmlspecialchars($section['semester']) ?>">
                                        <input type="hidden" name="year" value="<?= htmlspecialchars($section['year']) ?>">
                                        <select name="grade">
                                            <option value="">Select Grade</option>
                                            <option value="A">A</option>
                                            <option value="A-">A-</option>
                                            <option value="B+">B+</option>
                                            <option value="B">B</option>
                                            <option value="B-">B-</option>
                                            <option value="C+">C+</option>
                                            <option value="C">C</option>
                                            <option value="C-">C-</option>
                                            <option value="D">D</option>
                                            <option value="F">F</option>
                                        </select>
                                        <button type="submit" name="submit_grade">Submit Grade</button>
                                    </form>
                                </td>
                            </tr>
                        <?php endforeach; ?>
                    </table>
                <?php else: ?>
                    <p>No students enrolled in this section.</p>
                <?php endif; ?>
            <?php endforeach; ?>
        <?php else: ?>
            <p>No course sections found.</p>
        <?php endif; ?>

        <a href="student.php?page=home"><button type="button">Back to Dashboard</button></a>
    </body>
    </html>
    <?php
    $stmt->close();
    $conn->close();
    exit;
}

// Rest of the student history code...
$student_id = get_student_id($user_id, $conn);

// Fetch registered courses with instructor name and calculate GPA
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

// Store results in array to calculate GPA
$courses = [];
while ($row = $result->fetch_assoc()) {
    $courses[] = $row;
}

// Calculate GPA for each semester
$semester_gpas = [];
foreach ($courses as $course) {
    $semester_key = $course['year'] . '_' . $course['semester'];
    
    if (!isset($semester_gpas[$semester_key])) {
        $semester_gpas[$semester_key] = [
            'total_points' => 0,
            'total_credits' => 0,
            'year' => $course['year'],
            'semester' => $course['semester']
        ];
    }
    
    if (!empty($course['grade'])) {
        $grade_points = 0;
        switch ($course['grade']) {
            case 'A': $grade_points = 4.0; break;
            case 'A-': $grade_points = 3.7; break;
            case 'B+': $grade_points = 3.3; break;
            case 'B': $grade_points = 3.0; break;
            case 'B-': $grade_points = 2.7; break;
            case 'C+': $grade_points = 2.3; break;
            case 'C': $grade_points = 2.0; break;
            case 'C-': $grade_points = 1.7; break;
            case 'D': $grade_points = 1.0; break;
            case 'F': $grade_points = 0.0; break;
        }
        $semester_gpas[$semester_key]['total_points'] += ($grade_points * $course['credits']);
        $semester_gpas[$semester_key]['total_credits'] += $course['credits'];
    }
}

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
    <style>
        .semester-header {
            background-color: #f0f0f0;
            padding: 10px;
            margin: 20px 0 10px 0;
        }
    </style>
</head>
<body>

<h1>My Courses</h1>

<?php if (isset($message)): ?>
    <p><?= $message ?></p>
<?php endif; ?>

<?php if (!empty($courses)): ?>
    <?php 
    $current_semester = '';
    foreach ($courses as $row): 
        $semester_key = $row['year'] . '_' . $row['semester'];
        if ($current_semester !== $semester_key):
            if ($current_semester !== ''): ?>
                </table>
            <?php endif; 
            $current_semester = $semester_key;
            $gpa = 0;
            if ($semester_gpas[$semester_key]['total_credits'] > 0) {
                $gpa = $semester_gpas[$semester_key]['total_points'] / $semester_gpas[$semester_key]['total_credits'];
            }
    ?>
        <div class="semester-header">
            <h2><?= htmlspecialchars($row['semester']) ?> <?= htmlspecialchars($row['year']) ?></h2>
            <p>Semester GPA: <?= number_format($gpa, 2) ?></p>
        </div>
        <table>
            <tr>
                <th>Course ID</th>
                <th>Course Name</th>
                <th>Section ID</th>
                <th>Credits</th>
                <th>Grade</th>
                <th>Instructor</th>
                <th>Rate Instructor</th>
            </tr>
        <?php endif; ?>
            <tr>
                <td><?= htmlspecialchars($row['course_id']) ?></td>
                <td><?= htmlspecialchars($row['course_name']) ?></td>
                <td><?= htmlspecialchars($row['section_id']) ?></td>
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
                            <p>Already rated</p>
                        <?php else: ?>
                            <!-- Rating Form -->
                            <form method="POST" action="">
                                <input type="hidden" name="instructor_id" value="<?= htmlspecialchars($row['instructor_id']) ?>">
                                <input type="hidden" name="course_id" value="<?= htmlspecialchars($row['course_id']) ?>">
                                <input type="hidden" name="section_id" value="<?= htmlspecialchars($row['section_id']) ?>">
                                <input type="number" id="rating" name="rating" min="1" max="5" required>
                                <button type="submit" name="submit_rating">Rate</button>
                            </form>
                        <?php endif; ?>
                    <?php endif; ?>
                </td>
            </tr>
    <?php endforeach; ?>
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

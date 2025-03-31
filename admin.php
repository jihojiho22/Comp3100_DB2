<?php
session_start();
require_once 'config&functions.php';

$user_id = $_SESSION['user_id'] ?? null;
$user_type = $_SESSION['user_type'] ?? null;
$page = isset($_GET['page']) ? $_GET['page'] : 'home';

// Check if user is logged in and is admin
if (!$user_id || $user_type !== 'admin') {
    header('Location: index.html');
    exit;
}

$conn = get_db_connection();

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Handle form submission for adding a new course
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $page === 'add_course') {
    $course_name = trim($_POST['course_name']);
    $course_id = trim($_POST['course_id']);
    $credits = trim($_POST['credits']);

    // Validate inputs
    if (empty($course_name) || empty($course_id) || empty($credits)) {
        $_SESSION['error_message'] = "All fields are required.";
        header("Location: admin.php?page=add_course");
        exit();
    }

    // Insert new course into database
    $insert_course = "INSERT INTO course (course_id, course_name, credits) VALUES (?, ?, ?)";
    $stmt = $conn->prepare($insert_course);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }
    $stmt->bind_param("sss", $course_id, $course_name, $credits);

    if ($stmt->execute()) {
        $_SESSION['success_message'] = "Course successfully added!";
        header("Location: admin.php?page=add_course");
        exit();
    } else {
        $_SESSION['error_message'] = "Error inserting course: " . $stmt->error;
        header("Location: admin.php?page=add_course");
        exit();
    }
}

// Handle form submission for assigning a new section
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $page === 'assign_section') {
    $course_id = trim($_POST['course_id']);
    $section_id = trim($_POST['section_id']);
    $semester = trim($_POST['semester']);
    $year = trim($_POST['year']);
    $instructor_id = trim($_POST['instructor_id']);
    $time_slot_id = trim($_POST['time_slot_id']);
    $classroom_id = 1;

    // Validate inputs
    if (empty($course_id) || empty($section_id) || empty($semester) || empty($year) || empty($instructor_id) || empty($time_slot_id) || empty($classroom_id)) {
        $_SESSION['error_message'] = "All fields are required.";
        header("Location: admin.php?page=assign_section");
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
        header("Location: admin.php?page=assign_section");
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
        header("Location: admin.php?page=assign_section");
        exit();
    }


    // Get the last used classroom ID and increment it by 1
    $get_last_classroom_id = "SELECT MAX(classroom_id) AS last_classroom_id FROM section";
    $stmt = $conn->prepare($get_last_classroom_id);
    if (!$stmt) {
        die("SQL Error: " . $conn->error);
    }
    $stmt->execute();
    $result = $stmt->get_result()->fetch_assoc();
    $classroom_id = isset($result['last_classroom_id']) ? $result['last_classroom_id'] + 1 : 1; 
    
    // Convert classroom_id to string format
    $classroom_id = strval($classroom_id);

    // Insert new section
    $insert_section = "INSERT INTO section (course_id, section_id, semester, year, instructor_id, classroom_id, time_slot_id) VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($insert_section);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }
    $stmt->bind_param("sssssss", $course_id, $section_id, $semester, $year, $instructor_id, $classroom_id, $time_slot_id);

    if ($stmt->execute()) {
        $_SESSION['success_message'] = "Course section successfully created!";
        $default_building = "Main";
        $default_room = "R" . $classroom_id;
        
        $stmt2 = $conn->prepare("INSERT INTO classroom (classroom_id, building, room_number, capacity) VALUES (?, ?, ?, 15)");
        if (!$stmt2) {
            die("Error preparing classroom insert: " . $conn->error);
        }
        
        $stmt2->bind_param("sss", $classroom_id, $default_building, $default_room);
        
        if (!$stmt2->execute()) {
            $_SESSION['error_message'] = "Section created but classroom not added: " . $stmt2->error;
        }
        
        $stmt2->close();
        header("Location: admin.php?page=assign_section");
        exit();
    } else {
        $_SESSION['error_message'] = "Error inserting data: " . $stmt->error;
        header("Location: admin.php?page=assign_section");
        exit();
    }
}

// Fetch courses to populate dropdown
$course_sql = "SELECT course_id, course_name FROM course";
$course_result = $conn->query($course_sql);

// Check if the query was successful and data is available
if (!$course_result) {
    die("SQL error: " . $conn->error);
}

if ($course_result->num_rows == 0) {
    $courses_empty = true;
} else {
    $courses_empty = false;
}

// Fetch instructors and time slots for dropdowns
$instructor_sql = "SELECT instructor_id, instructor_name FROM instructor";
$instructor_result = $conn->query($instructor_sql);

$timeslot_sql = "SELECT time_slot_id, day, start_time, end_time FROM time_slot";
$timeslot_result = $conn->query($timeslot_sql);

$advisor_sql = "SELECT instructor_id, instructor_name FROM instructor";
$advisor_result = $conn->query($advisor_sql);

// Fetch instructor ratings
$rating_sql = "SELECT i.instructor_id, i.instructor_name, AVG(ir.rating) as avg_rating 
               FROM instructor i
               LEFT JOIN instructor_rating ir ON i.instructor_id = ir.instructor_id
               GROUP BY i.instructor_id, i.instructor_name";
$rating_result = $conn->query($rating_sql);

// Handle form submission for appointing an advisor
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $page === 'appoint_advisor') {
    $instructor_id = trim($_POST['instructor_id']);
    $student_id = trim($_POST['student_id']);
    $start_date = trim($_POST['start_date']);
    $end_date = trim($_POST['end_date']);

    // Validate inputs
    if (empty($instructor_id) || empty($student_id) || empty($start_date)  || empty($end_date)) {
        $_SESSION['error_message'] = "Instructor, student, start date, and end date are required.";
        header("Location: admin.php?page=appoint_advisor");
        exit();
    }

    // Insert advisor record into the 'advise' table
    $insert_advisor = "INSERT INTO advise (instructor_id, student_id, start_date, end_date) VALUES (?, ?, ?, ?)";
    $stmt = $conn->prepare($insert_advisor);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }
    
    $stmt->bind_param("ssss", $instructor_id, $student_id, $start_date, $end_date);

    if ($stmt->execute()) {
        $_SESSION['success_message'] = "Advisor successfully appointed!";
        header("Location: admin.php?page=appoint_advisor");
        exit();
    } else {
        $_SESSION['error_message'] = "Error inserting data: " . $stmt->error;
        header("Location: admin.php?page=appoint_advisor");
        exit();
    }
}

// Assign TA to a course section
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $page === 'assign_ta') {
    $student_id = trim($_POST['student_id']);
    $selected_course = isset($_POST['selected_course']) ? trim($_POST['selected_course']) : null;

    // Validate inputs
    if (empty($student_id) || empty($selected_course)) {
        $_SESSION['error_message'] = "Student ID and course selection are required.";
        header("Location: admin.php?page=assign_ta");
        exit();
    }

    // Parse selected course details
    list($course_id, $section_id, $semester, $year) = explode("|", $selected_course);

    // Check if the student ID exists in the PhD table
    $check_phd = "SELECT * FROM PhD WHERE student_id = ?";
    $stmt = $conn->prepare($check_phd);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }
    $stmt->bind_param("s", $student_id);
    $stmt->execute();
    $result_phd = $stmt->get_result();

    if ($result_phd->num_rows == 0) {
        $_SESSION['error_message'] = "Invalid PhD student ID.";
        header("Location: admin.php?page=assign_ta");
        exit();
    }

    // Check if the student is already assigned as a TA for any section
    $check_ta = "SELECT * FROM TA WHERE student_id = ?";
    $stmt = $conn->prepare($check_ta);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }
    $stmt->bind_param("s", $student_id);
    $stmt->execute();
    $result_ta = $stmt->get_result();

    if ($result_ta->num_rows > 0) {
        $_SESSION['error_message'] = "Student is already assigned as a TA for another section.";
        header("Location: admin.php?page=assign_ta");
        exit();
    }

    // Insert into TA table
    $insert_ta = "INSERT INTO TA (student_id, course_id, section_id, semester, year) VALUES (?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($insert_ta);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }
    $stmt->bind_param("sssss", $student_id, $course_id, $section_id, $semester, $year);

    if ($stmt->execute()) {
        $_SESSION['success_message'] = "TA successfully assigned!";
        header("Location: admin.php?page=assign_ta");
        exit();
    } else {
        $_SESSION['error_message'] = "Error assigning TA: " . $stmt->error;
        header("Location: admin.php?page=assign_ta");
        exit();
    }
}

// Fetch available courses for TA
$sql = "SELECT *
FROM (
    SELECT s.*, c.course_name, c.credits, r.capacity, 
        (SELECT COUNT(*) FROM take t WHERE t.course_id = s.course_id AND t.section_id = s.section_id AND t.semester = s.semester AND t.year = s.year) AS enrolled_count 
    FROM section s 
    JOIN course c ON s.course_id = c.course_id 
    JOIN classroom r ON s.classroom_id = r.classroom_id
) AS subquery
WHERE enrolled_count >= 10;";
$result = $conn->query($sql);

// Assign an undergrader grader for a course section
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $page === 'assign_grader_undergrad') {
    $student_id = trim($_POST['student_id']);
    $selected_course = isset($_POST['selected_course']) ? trim($_POST['selected_course']) : null;

    // Validate inputs
    if (empty($student_id) || empty($selected_course)) {
        $_SESSION['error_message'] = "Student ID and course selection are required.";
        header("Location: admin.php?page=assign_grader_undergrad");
        exit();
    }

    // Parse selected course details
    list($course_id, $section_id, $semester, $year) = explode("|", $selected_course);

    // Check if student is undergrad student is a grader in any other secion
    $check_undergrad = 
        "SELECT student_id, course_id
        FROM undergraduateGrader
        WHERE student_id = ? AND course_id = ?";
    $stmt = $conn->prepare($check_undergrad);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }

    $stmt->bind_param("ss", $student_id, $section_id);
    $stmt->execute();
    $result_undergrad = $stmt->get_result();

    if ($result_undergrad->num_rows > 0) {
        $_SESSION['error_message'] = "Undergraduate student is already assigned as a grader for another section.";
        header("Location: admin.php?page=assign_grader_undergrad");
        exit();
    } 

    // check if undergrad has at least an A- in the course
    $check_undergrad = 
        "SELECT *
        FROM take
        WHERE student_id = ? AND course_id = ? AND (grade = 'A+' OR grade = 'A' OR grade = 'A-')";
    $stmt = $conn->prepare($check_undergrad);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }

    $stmt->bind_param("ss", $student_id, $course_id);
    $stmt->execute();
    $result_undergrad = $stmt->get_result();

    if ($result_undergrad->num_rows <= 0) {
        $_SESSION['error_message'] = "Undergrad student does not have at least an A- in this course.";
        header("Location: admin.php?page=assign_grader_undergrad");
        exit();
    } 
    
    // Insert into undergraduateGrader table
    $insert_undergrad = 
        "INSERT INTO undergraduateGrader (student_id, course_id, section_id, semester, year)
        VALUES (?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($insert_undergrad);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }

    $stmt->bind_param("sssss", $student_id, $course_id, $section_id, $semester, $year);

    if ($stmt->execute()) {
        $_SESSION['success_message'] = "Grader successfully assigned!";
        header("Location: admin.php?page=assign_grader_undergrad");
        exit();
    } else {
        $_SESSION['error_message'] = "Error assigning grader: " . $stmt->error;
        header("Location: admin.php?page=assign_grader_undergrad");
        exit();
    }
}


// Assign an master student grader for a course section
if ($_SERVER['REQUEST_METHOD'] === 'POST' && $page === 'assign_grader_master') {
    $student_id = trim($_POST['student_id']);
    $selected_course = isset($_POST['selected_course']) ? trim($_POST['selected_course']) : null;

    // Validate inputs
    if (empty($student_id) || empty($selected_course)) {
        $_SESSION['error_message'] = "Student ID and course selection are required.";
        header("Location: admin.php?page=assign_grader_master");
        exit();
    }

    // Parse selected course details
    list($course_id, $section_id, $semester, $year) = explode("|", $selected_course);

    // Check if student is master student is a grader in any other secion
    $check_master = 
        "SELECT student_id, course_id
        FROM masterGrader
        WHERE student_id = ? AND course_id = ?";
    $stmt = $conn->prepare($check_master);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }

    $stmt->bind_param("ss", $student_id, $section_id);
    $stmt->execute();
    $result_master = $stmt->get_result();

    if ($result_master->num_rows > 0) {
        $_SESSION['error_message'] = "Masters student is already assigned as a grader for another section.";
        header("Location: admin.php?page=assign_grader_master");
        exit();
    } 

    // check if master has at least an A- in the course
    $check_master = 
        "SELECT *
        FROM take
        WHERE student_id = ? AND course_id = ? AND (grade = 'A+' OR grade = 'A' OR grade = 'A-')";
    $stmt = $conn->prepare($check_master);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }

    $stmt->bind_param("ss", $student_id, $course_id);
    $stmt->execute();
    $result_master = $stmt->get_result();

    if ($result_master->num_rows <= 0) {
        $_SESSION['error_message'] = "Masters student does not have at least an A- in this course.";
        header("Location: admin.php?page=assign_grader_master");
        exit();
    } 

    // Insert into masterGrader table
    $insert_master = 
        "INSERT INTO masterGrader (student_id, course_id, section_id, semester, year)
        VALUES (?, ?, ?, ?, ?)";
    $stmt = $conn->prepare($insert_master);
    if (!$stmt) {
        die("Error preparing statement: " . $conn->error);
    }

    $stmt->bind_param("sssss", $student_id, $course_id, $section_id, $semester, $year);

    if ($stmt->execute()) {
        $_SESSION['success_message'] = "Grader successfully assigned!";
        header("Location: admin.php?page=assign_grader");
        exit();
    } else {
        $_SESSION['error_message'] = "Error assigning grader: " . $stmt->error;
        header("Location: admin.php?page=assign_grader");
        exit();
    }
}
// Fetch available courses for grader
$sql = 
    "SELECT *
    FROM (
        SELECT s.*, c.course_name, c.credits, r.capacity, 
            (SELECT COUNT(*) 
            FROM take t 
            WHERE t.course_id = s.course_id 
            AND t.section_id = s.section_id 
            AND t.semester = s.semester 
            AND t.year = s.year) AS enrolled_count 
        FROM section s 
        JOIN course c ON s.course_id = c.course_id 
        JOIN classroom r ON s.classroom_id = r.classroom_id
    ) AS subquery
    WHERE enrolled_count >= 5 AND enrolled_count < 10;";
$result = $conn->query($sql);
$conn->close();
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin</title>
</head>
<body>
    <!-- Display success/error messages if any -->
    <?php if (isset($_SESSION['success_message'])): ?>
        <div style="color: green; margin-bottom: 10px;">
            <?php 
                echo $_SESSION['success_message']; 
                unset($_SESSION['success_message']);
            ?>
        </div>
    <?php endif; ?>
    
    <?php if (isset($_SESSION['error_message'])): ?>
        <div style="color: red; margin-bottom: 10px;">
            <?php 
                echo $_SESSION['error_message']; 
                unset($_SESSION['error_message']);
            ?>
        </div>
    <?php endif; ?>

    <!-- Add Course Section -->
    <?php if ($page === 'add_course'): ?>
        <h1>Add New Course</h1>
        <form action="admin.php?page=add_course" method="post">
            <label for="course_name">Course Name:</label>
            <input type="text" name="course_name" required><br>

            <label for="course_id">Course ID:</label>
            <input type="text" name="course_id" required><br>

            <label for="credits">Credits:</label>
            <input type="text" name="credits" required><br>

            <input type="submit" value="Add Course">
        </form>
        <a href="student.php?page=home"><button>Back To Dashboard</button></a> 
    <?php endif; ?>

    <!-- Assign Section Section -->
    <?php if ($page === 'assign_section'): ?>
        <h1>Assign Course Section</h1>
        <form action="admin.php?page=assign_section" method="post">
            <label for="course_id">Select Course:</label>
            <select name="course_id" required>
                <option value="">Select a Course</option>
                <?php
                if ($courses_empty) {
                    echo "<option value=''>No courses available</option>";
                } else {
                    while ($course_row = $course_result->fetch_assoc()) {
                        echo "<option value='" . htmlspecialchars($course_row['course_id']) . "'>" 
                             . htmlspecialchars($course_row['course_id'] . " - " . $course_row['course_name']) 
                             . "</option>";
                    }
                }
                ?>
            </select><br>

            <label for="section_id">Section ID:</label>
            <input type="text" name="section_id" required><br>

            <label for="semester">Semester:</label>
            <select name="semester" required>
                <option value="">Select Semester</option>
                <option value="Fall">Fall</option>
                <option value="Winter">Winter</option>
                <option value="Spring">Spring</option>
                <option value="Summer">Summer</option>
            </select><br>

            <label for="year">Year:</label>
            <select name="year" required>
                <option value="">Select Year</option>
                <option value="2024">2024</option>
                <option value="2025">2025</option>
                <option value="2026">2026</option>
            </select><br>

            <label for="time_slot_id">Time Slot:</label>
            <select name="time_slot_id" required>
                <option value="">Select Time Slot</option>
                <?php
                if ($timeslot_result && $timeslot_result->num_rows > 0) {
                    while ($timeslot_row = $timeslot_result->fetch_assoc()) {
                        echo "<option value='" . htmlspecialchars($timeslot_row['time_slot_id']) . "'>" 
                             . htmlspecialchars($timeslot_row['day'] . " " . $timeslot_row['start_time'] . "-" . $timeslot_row['end_time']) 
                             . "</option>";
                    }
                } else {
                    echo "<option value=''>No time slots available</option>";
                }
                ?>
            </select><br>

            <label for="instructor_id">Select Instructor:</label>
            <select name="instructor_id" required>
                <option value="">Select an Instructor</option>
                <?php
                if ($instructor_result && $instructor_result->num_rows > 0) {
                    while ($instructor_row = $instructor_result->fetch_assoc()) {
                        echo "<option value='" . htmlspecialchars($instructor_row['instructor_id']) . "'>" 
                             . htmlspecialchars($instructor_row['instructor_id'] . " - " . $instructor_row['instructor_name']) 
                             . "</option>";
                    }
                } else {
                    echo "<option value=''>No instructors available</option>";
                }
                ?>
            </select><br>

            <input type="submit" value="Create Course Section">
        </form>
        <a href="student.php?page=home"><button>Back To Dashboard</button></a> 
    <?php endif; ?>

     <!-- Appoing Advisor Section -->
    <?php if ($page === 'appoint_advisor'): ?>
        <h1>Appoint Advisor</h1>
        <form action="admin.php?page=appoint_advisor" method="post">
            <label for="instructor_id">Select Instructor:</label>
            <select name="instructor_id" required>
                <option value="">Select an Instructor</option>
                <?php
                if ($advisor_result && $advisor_result->num_rows > 0) {
                    while ($advisor_row = $advisor_result->fetch_assoc()) {
                        echo "<option value='" . htmlspecialchars($advisor_row['instructor_id']) . "'>" 
                            . htmlspecialchars($advisor_row['instructor_name']) 
                            . "</option>";
                    }
                } else {
                    echo "<option value=''>No instructors available</option>";
                }
                ?>
            </select><br>

            <label for="student_id">Student ID:</label>
            <input type="text" name="student_id" required><br>

            <label for="start_date">Start Date:</label>
            <input type="date" name="start_date" required><br>

            <label for="end_date">End Date</label>
            <input type="date" name="end_date" required><br>

            <input type="submit" value="Appoint Advisor">
        </form>
        <a href="student.php?page=home"><button>Back To Dashboard</button></a> 
    <?php endif; ?>

    <!-- Instructor Ratings Section -->
    <?php if ($page === 'instructor_rating'): ?>
        <h1>Instructor Ratings</h1>
        <table border="1">
            <tr>
                <th>Instructor ID</th>
                <th>Instructor Name</th>
                <th>Average Rating</th>
            </tr>
            <?php
            if ($rating_result && $rating_result->num_rows > 0) {
                while ($rating_row = $rating_result->fetch_assoc()) {
                    echo "<tr>";
                    echo "<td>" . htmlspecialchars($rating_row['instructor_id']) . "</td>";
                    echo "<td>" . htmlspecialchars($rating_row['instructor_name']) . "</td>";
                    echo "<td>" . ($rating_row['avg_rating'] ? number_format($rating_row['avg_rating'], 2) : 'No ratings') . "</td>";
                    echo "</tr>";
                }
            } else {
                echo "<tr><td colspan='3'>No ratings available</td></tr>";
            }
            ?>
        </table>
        <a href="student.php?page=home"><button>Back To Dashboard</button></a>
    <?php endif; ?>

    <!-- Assign TA Section -->
    <?php if ($page === 'assign_ta'): ?>
    <h1>Assign TA</h1>
    <h2>Available Courses for TA (Displaying courses with at least 10 students enrolled)</h2>

    <form action="admin.php?page=assign_ta" method="post">
        <label for="student_id">PhD Student ID:</label>
        <input type="text" name="student_id" required><br><br>

        <?php if ($result->num_rows > 0): ?>
            <ul>
                <?php while ($row = $result->fetch_assoc()): ?>
                    <li>
                        <input type="radio" name="selected_course" value="<?php echo htmlspecialchars($row["course_id"] . "|" . $row["section_id"] . "|" . $row["semester"] . "|" . $row["year"]); ?>">
                        <strong>Course ID:</strong> <?php echo htmlspecialchars($row["course_id"]); ?> -
                        <strong>Section:</strong> <?php echo htmlspecialchars($row["section_id"]); ?> -
                        <strong>Course Name:</strong> <?php echo htmlspecialchars($row["course_name"]); ?> -
                        <strong>Semester:</strong> <?php echo htmlspecialchars($row["semester"]); ?> -
                        <strong>Year:</strong> <?php echo htmlspecialchars($row["year"]); ?> -
                        <strong>Credits:</strong> <?php echo htmlspecialchars($row["credits"]); ?> -
                        <strong>Capacity:</strong> <?php echo htmlspecialchars($row["enrolled_count"]); ?> / <?php echo htmlspecialchars($row["capacity"]); ?>
                    </li>
                <?php endwhile; ?>
            </ul>
            <button type="submit">Assign TA</button>
        <?php else: ?>
            <p>No available courses found.</p>
        <?php endif; ?>
    </form>
    <a href="student.php?page=home"><button>Back To Dashboard</button></a>
<?php endif; ?>

<!-- Assign Grader Undergrad Section -->
    <?php if ($page === 'assign_grader_undergrad'): ?>
        <h1>Assign Undergraduate Grader</h1>
        <h2>Available Courses for Undergraduate Grader (Displaying courses with 5 to 10 students enrolled)</h2>

        <form action="admin.php?page=assign_grader_undergrad" method="post">
            <label for="student_id">Undergraduate Student ID:</label>
            <input type="text" name="student_id" required><br><br>

            <?php if ($result->num_rows > 0): ?>
                <ul>
                    <?php while ($row = $result->fetch_assoc()): ?>
                        <li>
                            <input type="radio" name="selected_course" value="<?php echo htmlspecialchars($row["course_id"] . "|" . $row["section_id"] . "|" . $row["semester"] . "|" . $row["year"]); ?>">
                            <strong>Course ID:</strong> <?php echo htmlspecialchars($row["course_id"]); ?> -
                            <strong>Section:</strong> <?php echo htmlspecialchars($row["section_id"]); ?> -
                            <strong>Course Name:</strong> <?php echo htmlspecialchars($row["course_name"]); ?> -
                            <strong>Semester:</strong> <?php echo htmlspecialchars($row["semester"]); ?> -
                            <strong>Year:</strong> <?php echo htmlspecialchars($row["year"]); ?> -
                            <strong>Credits:</strong> <?php echo htmlspecialchars($row["credits"]); ?> -
                            <strong>Capacity:</strong> <?php echo htmlspecialchars($row["enrolled_count"]); ?> / <?php echo htmlspecialchars($row["capacity"]); ?>
                        </li>
                    <?php endwhile; ?>
                </ul>
                <button type="submit">Assign Grader</button>
            <?php else: ?>
                <p>No available courses found.</p>
            <?php endif; ?>
        </form>
        <a href="student.php?page=home"><button>Back To Dashboard</button></a>
    <?php endif; ?>

    <!-- Assign Grader Master Section -->
    <?php if ($page === 'assign_grader_master'): ?>
        <h1>Assign Master Grader</h1>
        <h2>Available Courses for Master Grader (Displaying courses with 5 to 10 students enrolled)</h2>

        <form action="admin.php?page=assign_grader_master" method="post">
            <label for="student_id">Master Student ID:</label>
            <input type="text" name="student_id" required><br><br>

            <?php if ($result->num_rows > 0): ?>
                <ul>
                    <?php while ($row = $result->fetch_assoc()): ?>
                        <li>
                            <input type="radio" name="selected_course" value="<?php echo htmlspecialchars($row["course_id"] . "|" . $row["section_id"] . "|" . $row["semester"] . "|" . $row["year"]); ?>">
                            <strong>Course ID:</strong> <?php echo htmlspecialchars($row["course_id"]); ?> -
                            <strong>Section:</strong> <?php echo htmlspecialchars($row["section_id"]); ?> -
                            <strong>Course Name:</strong> <?php echo htmlspecialchars($row["course_name"]); ?> -
                            <strong>Semester:</strong> <?php echo htmlspecialchars($row["semester"]); ?> -
                            <strong>Year:</strong> <?php echo htmlspecialchars($row["year"]); ?> -
                            <strong>Credits:</strong> <?php echo htmlspecialchars($row["credits"]); ?> -
                            <strong>Capacity:</strong> <?php echo htmlspecialchars($row["enrolled_count"]); ?> / <?php echo htmlspecialchars($row["capacity"]); ?>
                        </li>
                    <?php endwhile; ?>
                </ul>
                <button type="submit">Assign Grader</button>
            <?php else: ?>
                <p>No available courses found.</p>
            <?php endif; ?>
        </form>
        <a href="student.php?page=home"><button>Back To Dashboard</button></a>
    <?php endif; ?>


</body>
</html>

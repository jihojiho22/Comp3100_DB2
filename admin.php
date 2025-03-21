<?php
session_start();
require_once 'config&functions.php';

$user_id = $_SESSION['user_id'];
$user_type = $_SESSION['user_type'];
$page = isset($_GET['page']) ? $_GET['page'] : null;

require_login();

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

</body>
</html>
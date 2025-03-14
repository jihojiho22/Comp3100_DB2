<?php
session_start();
require_once 'functions.php';
require_login();

$conn = get_db_connection();

$user_id = $_SESSION['user_id'];
$user_type = $_SESSION['user_type'];
?>
<!DOCTYPE html>
<html>
<head>
    <title>Assign Course</title>
    <meta charset="UTF-8">
</head>
<body>

<?php
if (isset($_SESSION['success_message'])) {
    echo "<p style='color: green;'>" . htmlspecialchars($_SESSION['success_message']) . "</p>";
    unset($_SESSION['success_message']);
}

if (isset($_SESSION['error_message'])) {
    echo "<p style='color: red;'>" . htmlspecialchars($_SESSION['error_message']) . "</p>";
    unset($_SESSION['error_message']);
}
?>

<h1>Assign Course</h1>

<?php if (is_admin()): ?>
    <h3>Add New Course Section</h3>
    <form action="add_section.php" method="post">
        <label for="course_id">Select Course:</label>
        <select name="course_id" required>
            <option value="">Select a Course</option>
            <?php
            $course_sql = "SELECT course_id, course_name FROM course";
            $course_result = $conn->query($course_sql);
            while ($course_row = $course_result->fetch_assoc()) {
                echo "<option value='" . htmlspecialchars($course_row['course_id']) . "'>" 
                     . htmlspecialchars($course_row['course_id'] . " - " . $course_row['course_name']) 
                     . "</option>";
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
        <input type="number" name="year" required><br>

        <label for="time_slot_id">Time Slot:</label>
        <select name="time_slot_id" required>
            <option value="">Select Time Slot</option>
            <?php
            $timeslot_sql = "SELECT time_slot_id, day, start_time, end_time FROM time_slot";
            $timeslot_result = $conn->query($timeslot_sql);
            while ($timeslot_row = $timeslot_result->fetch_assoc()) {
                echo "<option value='" . htmlspecialchars($timeslot_row['time_slot_id']) . "'>" 
                     . htmlspecialchars($timeslot_row['day'] . " " . $timeslot_row['start_time'] . "-" . $timeslot_row['end_time']) 
                     . "</option>";
            }
            ?>
        </select><br>

        <label for="instructor_id">Select Instructor:</label>
        <select name="instructor_id" required>
            <option value="">Select an Instructor</option>
            <?php
            $instructor_sql = "SELECT instructor_id, instructor_name FROM instructor";
            $instructor_result = $conn->query($instructor_sql);
            while ($instructor_row = $instructor_result->fetch_assoc()) {
                echo "<option value='" . htmlspecialchars($instructor_row['instructor_id']) . "'>" 
                     . htmlspecialchars($instructor_row['instructor_id'] . " - " . $instructor_row['instructor_name']) 
                     . "</option>";
            }
            ?>
        </select><br>

        <label for="classroom_id">Classroom ID:</label>
        <input type="text" name="classroom_id" required><br>

        <input type="submit" value="Create Course Section">
    </form>
<?php endif; ?>

<a href="dashboard.php"><button type="button">Back to Dashboard</button></a>
</body>
</html>
<?php
$conn->close();
?>

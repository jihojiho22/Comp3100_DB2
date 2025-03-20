<?php
session_start();
require_once 'config&functions.php';

// Default page is 'home' if no parameter is passed
$page = isset($_GET['page']) ? $_GET['page'] : 'home';

$conn = get_db_connection();

$email = $_SESSION['form_data']['email'] ?? '';
$error_messages = $_SESSION['error_messages'] ?? [];
$success_message = $_SESSION['success_message'] ?? '';

$user_id = $_SESSION['user_id'] ?? null;
$user_type = $_SESSION['user_type'] ?? null;

// Fetch the student_id for the current user if the user type is 'student'
$student_id = null;
if ($user_type === 'student') {
    $student_id = get_student_id($user_id, $conn);
}

$instructor_id = null;
if ($user_type === 'instructor') {
    $instructor_id = get_instructor_id($user_id, $conn);
}

// Fetch departments
$departments = [];
$result = $conn->query("SELECT dept_name FROM department"); 
while ($row = $result->fetch_assoc()) {
    $departments[] = $row['dept_name'];
}

// Handle password update submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_password'])) {
    $current_password = $_POST['current_password'] ?? '';
    $new_password = $_POST['new_password'] ?? '';
    $confirm_password = $_POST['confirm_password'] ?? '';
    
    $error_messages = [];

    // Verify current password
    list($success, $_) = verify_login($user_id, $current_password);
    if (!$success) {
        $error_messages[] = "Current password is incorrect.";
    }

    // Check if new passwords match
    if ($new_password !== $confirm_password) {
        $error_messages[] = "New passwords do not match.";
    }

    // Validate new password strength
    list($is_valid, $password_errors) = validate_password($new_password);
    if (!$is_valid) {
        $error_messages = array_merge($error_messages, $password_errors);
    }

    // Update the password
    if (empty($error_messages)) {
        list($success, $error) = update_password($user_id, $new_password);
        if ($success) {
            $success_message = "Password updated successfully!";
        } else {
            $error_messages[] = "Failed to update password: " . $error;
        }
    }

    $_SESSION['error_messages'] = $error_messages;
    $_SESSION['success_message'] = $success_message;
    header("Location: student.php?page=modify_profile");
    exit;
}

// Handle account creation submission
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['create_account'])) {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $confirm_password = $_POST['confirm_password'] ?? '';
    $name = $_POST['name'] ?? '';
    $dept_name = $_POST['dept_name'] ?? '';
    $degree = $_POST['degree'] ?? '';

    // Save form data in case of validation errors
    $_SESSION['form_data'] = ['email' => $email];

    $error_messages = [];

    // Validate email format
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $error_messages[] = "Invalid email format.";
    }

    // Check if passwords match
    if ($password !== $confirm_password) {
        $error_messages[] = "Passwords do not match.";
    }

    // Validate password strength
    list($is_valid, $password_errors) = validate_password($password);
    if (!$is_valid) {
        $error_messages = array_merge($error_messages, $password_errors);
    }

    // Check if user already exists
    if (user_exists($email)) {
        $error_messages[] = "Email already registered.";
    }

    // Reload
    if (!empty($error_messages)) {
        $_SESSION['error_messages'] = $error_messages;
        header('Location: student.php?page=create_account');
        exit;
    }

    // Create account
    list($success, $error) = create_account($email, $password, $name, $dept_name, $degree);

    if ($success) {
        unset($_SESSION['form_data']);
        $_SESSION['success_message'] = "Account created successfully!";
        header('Location: index.html');
        exit;
    } else {
        $_SESSION['error_messages'] = ["Failed to create account: " . $error];
        header('Location: student.php?page=create_account');
        exit;
    }
}

// Clear session variables
unset($_SESSION['error_messages'], $_SESSION['success_message'], $_SESSION['form_data']);
?>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Student Portal</title>
</head>
<body>
    <div class="content">
        <?php
        switch ($page) {
            case 'home':
                ?>
                <nav>
                    <a href="student.php?page=home">Home</a> | 
                    <a href="student.php?page=modify_profile">Modify Profile</a> |
                    <a href="logout.php">Logout</a>
                </nav>

                <h1>Dashboard</h1>
                <p>Welcome, <?php echo htmlspecialchars($user_id); ?></p>
                <p>Account type: <?php echo htmlspecialchars($user_type); ?></p>
                
                <?php if ($user_type === 'student' && $student_id): ?>
                    <p>Student ID: <?php echo htmlspecialchars($student_id); ?></p>
                <?php endif; ?>

                <?php if ($user_type === 'instructor'): ?>
                    <p>Instructor ID: <?php echo htmlspecialchars($instructor_id); ?></p>
                <?php endif; ?>

                
                <?php if (!is_admin() && !is_instructor()): ?>
                    <a href="student_register.php"><button type="button">Register Course</button></a>
                    <a href="student_history.php?page=my_courses"><button type="button">View My Course</button></a>
                    <a href="student_drop.php"><button type="button">Drop A Course</button></a>
                <?php endif; ?>

                <?php if (is_admin()): ?>
                    <a href="admin.php?page=add_course"><button type="button">Add Course</button></a>
                    <a href="admin.php?page=assign_section"><button type="button">Assign Section</button></a>
                <?php endif; ?>

                <?php if (is_admin() || is_instructor()): ?>
                    <a href="admin.php?page=appoint_advisor"><button type="button">Appoint Advisor</button></a>
                <?php endif; ?>

                <?php if (is_instructor()): ?>
                    <a href="student_history.php?page=course_records"><button type="button">View Course Records</button></a>
                <?php endif; ?>
                <?php
                break;

            case 'create_account':
                ?>
                <h2>Create Account</h2>
                
                <?php if (!empty($error_messages)): ?>
                <div style="color: red;">
                    <ul>
                        <?php foreach ($error_messages as $message): ?>
                        <li><?php echo htmlspecialchars($message); ?></li>
                        <?php endforeach; ?>
                    </ul>
                </div>
                <?php endif; ?>

                <form action="student.php?page=create_account" method="POST">
                    <input type="hidden" name="create_account" value="1">
                    <label>Email: </label>
                    <input type="email" name="email" value="<?php echo htmlspecialchars($email); ?>" required>
                    <br><br>
                    <label>Name: </label>
                    <input type="text" name="name" required>
                    <br><br>
                    <label>Department: </label>
                    <select name="dept_name" required>
                        <option value="">Select Department</option>
                        <?php foreach ($departments as $dept): ?>
                            <option value="<?php echo htmlspecialchars($dept); ?>"><?php echo htmlspecialchars($dept); ?></option>
                        <?php endforeach; ?>
                    </select>
                    <br><br>
                    <label>Degree Level:</label>
                    <select name="degree">
                        <option value="undergraduate">Undergraduate</option>
                        <option value="master">Master's</option>
                        <option value="PhD">PhD</option>
                    </select>
                    <br><br>
                    <label>Password: </label>
                    <input type="password" name="password" required>
                    <br><br>
                    <label>Confirm Password: </label>
                    <input type="password" name="confirm_password" required>
                    <br><br>
                    <button type="submit">Create Account</button>
                </form>
                <a href="index.html"><button>Back To Login</button></a> 
                <?php
                break;

            case 'modify_profile':
                ?>
                <h2>Modify Profile</h2>
                
                <form action="student.php?page=modify_profile" method="POST">
                    <input type="hidden" name="update_password" value="1">
                    <label>Current Password: </label>
                    <input type="password" name="current_password" required>
                    <br><br>
                    <label>New Password: </label>
                    <input type="password" name="new_password" required>
                    <br><br>
                    <label>Confirm New Password: </label>
                    <input type="password" name="confirm_password" required>
                    <br><br>
                    <button type="submit">Update Password</button>
                </form>
                <a href="student.php?page=home"><button>Back To Dashboard</button></a> 
                <?php
                break;

            default:
                echo "<p>Page not found.</p>";
        }
        ?>
    </div>
</body>
</html>

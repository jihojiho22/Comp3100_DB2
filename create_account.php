<?php
session_start();
require_once 'functions.php';

$conn = get_db_connection();

// If user is already logged in, redirect to dashboard
if (isset($_SESSION['user_id'])) {
    header('Location: dashboard.php');
    exit;
}

$email = isset($_SESSION['form_data']['email']) ? $_SESSION['form_data']['email'] : '';
$error_messages = isset($_SESSION['error_messages']) ? $_SESSION['error_messages'] : [];

$departments = [];
$result = $conn->query("SELECT dept_name FROM department"); 

while ($row = $result->fetch_assoc()) {
    $departments[] = $row['dept_name'];
}


// Clear session variables
if (isset($_SESSION['error_messages'])) {
    unset($_SESSION['error_messages']);
}

if (isset($_SESSION['form_data'])) {
    unset($_SESSION['form_data']);
}
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Account</title>
</head>
<body>
    <h2>Create Account</h2>
    
    <?php if (!empty($error_messages)): ?>
    <div>
        <p><strong>Please fix the following errors:</strong></p>
        <ul>
            <?php foreach ($error_messages as $message): ?>
            <li style="color: red;"><?php echo $message; ?></li>
            <?php endforeach; ?>
        </ul>
    </div>
    <?php endif; ?>
    
    <div>
        <p><strong>Password Requirements:</strong></p>
        <ul>
            <li>At least 8 characters long</li>
            <li>At least one uppercase letter</li>
            <li>At least one lowercase letter</li>
            <li>At least one number</li>
            <li>At least one special character</li>
        </ul>
    </div>
    
    <form action="process_account.php" method="POST">
        <label for="email">Email: </label>
        <input type="email" id="email" name="email" value="<?php echo htmlspecialchars($email); ?>" required>
        <br><br><br>
        <label for="name">Name: </label>
        <input type="name" id="name" name="name" required>
        <br><br><br>
        <label for="dept_name">Department: </label>
        <select id="dept_name" name="dept_name" required>
            <option value="">Select Department</option>
            <?php foreach ($departments as $dept): ?>
                <option value="<?php echo htmlspecialchars($dept); ?>"><?php echo htmlspecialchars($dept); ?></option>
            <?php endforeach; ?>
        </select>
        <br><br><br>
        <label for="degree">Select Your Degree Level:</label>
        <select id="degree" name="degree">
            <option value="undergraduate">Undergraduate</option>
            <option value="master">Master's</option>
            <option value="PhD">PhD</option>
        </select>
        <br><br><br>
        <label for="password">Password: </label>
        <input type="password" id="password" name="password" required>
        <br><br><br>
        <label for="confirm_password">Confirm Password: </label>
        <input type="password" id="confirm_password" name="confirm_password" required>
        <br><br><br>
        <button type="submit">Create Account</button>
    </form>
    <br><br>
    <a href="index.php"><button type="button">Back to Login</button></a>
</body>
</html>
<?php
session_start();
require_once 'functions.php';

// Require login to access this page
require_login();

$user_id = $_SESSION['user_id'];
$success_message = isset($_SESSION['success_message']) ? $_SESSION['success_message'] : '';
$error_messages = isset($_SESSION['error_messages']) ? $_SESSION['error_messages'] : [];

// Clear session messages
if (isset($_SESSION['success_message'])) {
    unset($_SESSION['success_message']);
}

if (isset($_SESSION['error_messages'])) {
    unset($_SESSION['error_messages']);
}
?>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Modify Profile</title>
</head>
<body>
    <h2>Modify Profile</h2>
    
    <?php if (!empty($success_message)): ?>
    <div style="color: green;">
        <p><?php echo $success_message; ?></p>
    </div>
    <?php endif; ?>
    
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
    
    <h3>Change Password</h3>
    <form action="update_password.php" method="POST">
        <label for="current_password">Current Password: </label>
        <input type="password" id="current_password" name="current_password" required>
        <br><br>
        <label for="new_password">New Password: </label>
        <input type="password" id="new_password" name="new_password" required>
        <br><br>
        <label for="confirm_password">Confirm New Password: </label>
        <input type="password" id="confirm_password" name="confirm_password" required>
        <br><br>
        <button type="submit">Update Password</button>
    </form>
    
    <br><br>
    <a href="dashboard.php"><button type="button">Back to Dashboard</button></a>
</body>
</html>
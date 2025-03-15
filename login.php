<?php
session_start();
require_once 'config&functions.php';

// Check if the user is already logged in
if (isset($_SESSION['user_id'])) {
    // Redirect to student.php or another page (e.g., dashboard)
    header('Location: student.php?page=home');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';

    // Verify user credentials
    list($success, $user_data) = verify_login($email, $password);

    if ($success) {
        // Set session variables
        $_SESSION['user_id'] = $email;
        $_SESSION['user_type'] = $user_data['type'];
        
        // Redirect to the home page
        header('Location: student.php?page=home');
        exit;
    } else {
        $_SESSION['login_error'] = "Invalid email or password.";
        header('Location: index.html'); // Redirect to login page with error
        exit;
    }
} else {
    // If accessed directly without POST, redirect to login page
    header('Location: index.html');
    exit;
}
?>

<?php
session_start();
require_once 'config_functions.php';

// Check if the user is already logged in
if (isset($_SESSION['user_id'])) {
    header('Location: student.php?page=home');
    exit;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';

    list($success, $user_data) = verify_login($email, $password);

    if ($success) {
        $_SESSION['user_id'] = $email;
        $_SESSION['user_type'] = $user_data['type'];
        
        header('Location: student.php?page=home');
        exit;
    } else {
        $_SESSION['login_error'] = "Invalid email or password.";
        header('Location: index.html');
        exit;
    }
} else {
    header('Location: index.html');
    exit;
}
?>

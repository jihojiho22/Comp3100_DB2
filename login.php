<?php
session_start();
require_once 'functions.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    
    list($success, $user_data) = verify_login($email, $password);
    
    if ($success) {
        // Set session variables
        $_SESSION['user_id'] = $email;
        $_SESSION['user_type'] = $user_data['type'];
        
        header('Location: dashboard.php');
        exit;
    } else {
        $_SESSION['login_error'] = "Invalid email or password.";
        header('Location: index.php');
        exit;
    }
} else {
    // If accessed directly without POST, redirect to login page
    header('Location: index.php');
    exit;
}
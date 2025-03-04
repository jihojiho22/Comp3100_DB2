<?php
session_start();
require_once 'functions.php';

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $password = $_POST['password'] ?? '';
    $confirm_password = $_POST['confirm_password'] ?? '';
    
    // Save form data in case of validation errors
    $_SESSION['form_data'] = [
        'email' => $email
    ];
    
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
    
    // If there are errors, redirect back to the create account page
    if (!empty($error_messages)) {
        $_SESSION['error_messages'] = $error_messages;
        header('Location: create_account.php');
        exit;
    }
    
    // Create account
    list($success, $error) = create_account($email, $password);
    
    if ($success) {
        // Clear session form data
        unset($_SESSION['form_data']);
        
        // Redirect to login page with success message
        $_SESSION['success_message'] = "Account created successfully!";
        header('Location: index.php');
        exit;
    } else {
        $_SESSION['error_messages'] = ["Failed to create account: " . $error];
        header('Location: create_account.php');
        exit;
    }
} else {
    // If accessed directly without POST, redirect to create account page
    header('Location: create_account.php');
    exit;
}
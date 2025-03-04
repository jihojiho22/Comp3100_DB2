<?php
session_start();
require_once 'functions.php';

// Require login to access this page
require_login();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $user_id = $_SESSION['user_id'];
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
    
    // If no errors, update the password
    if (empty($error_messages)) {
        list($success, $error) = update_password($user_id, $new_password);
        
        if ($success) {
            $_SESSION['success_message'] = "Password updated successfully!";
        } else {
            $_SESSION['error_messages'] = ["Failed to update password: " . $error];
        }
    } else {
        $_SESSION['error_messages'] = $error_messages;
    }
    
    header('Location: modify_profile.php');
    exit;
} else {
    // If accessed directly without POST, redirect to profile page
    header('Location: modify_profile.php');
    exit;
}
<?php
/**
 * Database connection
 */
function get_db_connection() {
    $servername = "localhost"; 
    $username = "root";         
    $password = "";          
    $dbname = "DB2";
    
    $conn = new mysqli($servername, $username, $password, $dbname);
    
    if ($conn->connect_error) {
        die("Connection failed: " . $conn->connect_error);
    }
    
    return $conn;
}

/**
 * Validate password strength
 * Returns [is_valid, error_messages]
 */
function validate_password($password) {
    $error_messages = [];
    
    if (strlen($password) < 8) {
        $error_messages[] = "Password must be at least 8 characters long";
    }
    
    if (!preg_match('/[A-Z]/', $password)) {
        $error_messages[] = "Password must contain at least one uppercase letter";
    }
    
    if (!preg_match('/[a-z]/', $password)) {
        $error_messages[] = "Password must contain at least one lowercase letter";
    }
    
    if (!preg_match('/[0-9]/', $password)) {
        $error_messages[] = "Password must contain at least one number";
    }
    
    if (!preg_match('/[!@#$%^&*(),.?":{}|<>]/', $password)) {
        $error_messages[] = "Password must contain at least one special character";
    }
    
    return [empty($error_messages), $error_messages];
}

/**
 * Check if a user exists by email
 */
function user_exists($email) {
    $conn = get_db_connection();
    
    $sql = "SELECT * FROM account WHERE email = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $result = $stmt->get_result();
    
    $exists = $result->num_rows > 0;
    
    $stmt->close();
    $conn->close();
    
    return $exists;
}

/**
 * Verify user login credentials
 * Returns [success, user_data]
 */
function verify_login($email, $password) {
    $conn = get_db_connection();
    
    $sql = "SELECT * FROM account WHERE email = ? AND password = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $email, $password);
    $stmt->execute();
    $result = $stmt->get_result();
    
    if ($result->num_rows > 0) {
        $user_data = $result->fetch_assoc();
        $stmt->close();
        $conn->close();
        return [true, $user_data];
    } else {
        $stmt->close();
        $conn->close();
        return [false, null];
    }
}

/**
 * Create a new user account
 * Returns [success, error_message]
 */
function create_account($email, $password) {
    $conn = get_db_connection();
    
    // Default type for new users is 'student'
    $type = 'student';
    
    $sql = "INSERT INTO account (email, password, type) VALUES (?, ?, ?)";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sss", $email, $password, $type);
    
    try {
        if ($stmt->execute()) {
            $stmt->close();
            $conn->close();
            return [true, ""];
        } else {
            $error = $stmt->error;
            $stmt->close();
            $conn->close();
            return [false, "Database error: " . $error];
        }
    } catch (Exception $e) {
        $stmt->close();
        $conn->close();
        return [false, "Exception: " . $e->getMessage()];
    }
}

/**
 * Update user password
 * Returns [success, error_message]
 */
function update_password($email, $new_password) {
    $conn = get_db_connection();
    
    $sql = "UPDATE account SET password = ? WHERE email = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ss", $new_password, $email);
    
    if ($stmt->execute()) {
        $stmt->close();
        $conn->close();
        return [true, ""];
    } else {
        $error = $stmt->error;
        $stmt->close();
        $conn->close();
        return [false, "Database error: " . $error];
    }
}

/**
 * Check if user is logged in, if not redirect to login page
 */
function require_login() {
    if (!isset($_SESSION['user_id'])) {
        header('Location: index.php');
        exit;
    }
}

/**
 * Check if current user is admin
 */
function is_admin() {
    if (!isset($_SESSION['user_type'])) {
        return false;
    }
    return $_SESSION['user_type'] === 'admin';
}

/**
 * Check if current user is instructor
 */
function is_instructor() {
    if (!isset($_SESSION['user_type'])) {
        return false;
    }
    return $_SESSION['user_type'] === 'instructor';
}
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

// Function to get student ID based on the user's email
function get_student_id($user_email, $conn) {
    $stmt = $conn->prepare("SELECT student_id FROM student WHERE email = ?");
    $stmt->bind_param("s", $user_email);
    $stmt->execute();
    $stmt->bind_result($student_id);  
    $stmt->fetch();
    $stmt->close();

    return $student_id;  
}

/**
 * Create a new user account
 * Returns [success, error_message]
 */
function create_account($email, $password, $name, $dept_name, $degree) {
    $conn = get_db_connection();
    
    // Default type for new users is 'student'
    $type = 'student';
    
    // First, insert into the account table
    $sql_account = "INSERT INTO account (email, password, type) VALUES (?, ?, ?)";
    $stmt_account = $conn->prepare($sql_account);
    $stmt_account->bind_param("sss", $email, $password, $type);
    
    try {
        if ($stmt_account->execute()) {
            $stmt_account->close();

            // Generate unique student_id
            $student_id = generate_unique_student_id($conn);
            
            // Insert into the student table
            $sql_student = "INSERT INTO student (student_id, name, email, dept_name) VALUES (?, ?, ?, ?)";
            $stmt_student = $conn->prepare($sql_student);
            $stmt_student->bind_param("ssss", $student_id, $name, $email, $dept_name);

            if ($stmt_student->execute()) {
                $stmt_student->close();

            // Insert into the degree tables
                if ($degree === 'undergraduate') {
                    $sql_degree = "INSERT INTO undergraduate (student_id, total_credits, class_standing) VALUES (?, NULL, NULL)";
                } elseif ($degree === 'master') {
                    $sql_degree = "INSERT INTO master (student_id, total_credits) VALUES (?, NULL)";
                } elseif ($degree === 'PhD') {
                    $sql_degree = "INSERT INTO PhD (student_id, qualifier, proposal_defence_date, dissertation_defence_date) VALUES (?, NULL, NULL, NULL)";
                } else {
                    $conn->close();
                    return [false, "Invalid degree type."];
                }

                $stmt_degree = $conn->prepare($sql_degree);
                $stmt_degree->bind_param("s", $student_id);

                if ($stmt_degree->execute()) {
                    $stmt_degree->close();
                    $conn->close();
                    return [true, ""];
                } else {
                    $error = $stmt_degree->error;
                    $stmt_degree->close();
                    $conn->close();
                    return [false, "Database error in degree table: " . $error];
                }
            } else {
                $error = $stmt_student->error;
                $stmt_student->close();
                $conn->close();
                return [false, "Database error in student table: " . $error];
            }
        } else {
            $error = $stmt_account->error;
            $stmt_account->close();
            $conn->close();
            return [false, "Database error in account table: " . $error];
        }
    } catch (Exception $e) {
        $conn->close();
        return [false, "Exception: " . $e->getMessage()];
    }
}



function generate_unique_student_id($conn) {
    do {
        $student_id = random_int(10000000, 99999999);
        $stmt = $conn->prepare("SELECT student_id FROM student WHERE student_id = ?");
        $stmt->bind_param("s", $student_id);
        $stmt->execute();
        $stmt->store_result();
    } while ($stmt->num_rows > 0);

    $stmt->close();
    return $student_id;
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
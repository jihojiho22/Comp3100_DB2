<?php
// Set response headers for JSON
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

// Database
$servername = "localhost";
$username = "root";
$password = "";
$dbname = "DB2";

error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    // Establish a connection to the MySQL database
    $conn = new PDO("mysql:host=$servername;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    $method = $_SERVER['REQUEST_METHOD'];
    $rawData = file_get_contents('php://input');
    $data = json_decode($rawData, true);

    if ($method == 'POST') {
        $action = $data['action'] ?? '';

        if ($action == 'create') {
            $email = $data['email'] ?? '';
            $name = $data['name'] ?? '';
            $password = $data['password'] ?? '';
            $type = $data['type'] ?? 'student';
            $dept_name = $data['dept_name'] ?? null;

            // Validate inputs
            if (empty($email) || empty($password) || empty($name)) {
                echo json_encode(['success' => false, 'message' => 'All fields are required']);
                exit;
            }

            // Check if email already exists
            $stmt = $conn->prepare("SELECT email FROM account WHERE email = ?");
            $stmt->execute([$email]);
            if ($stmt->rowCount() > 0) {
                echo json_encode(['success' => false, 'message' => 'Email already exists']);
                exit;
            }

            try {
                $conn->beginTransaction();
                
                // Insert new account into the database
                $stmt = $conn->prepare("INSERT INTO account (email, password, type) VALUES (?, ?, ?)");
                $stmt->execute([$email, $password, $type]);
                
                $student_id = null;
                
                // If account type is student, create student record
                if ($type == 'student') {
                    // Generate a unique student ID
                    do {
                        $student_id = 'S' . substr(str_shuffle('0123456789'), 0, 9);
                        
                        // Check if this ID already exists
                        $checkStmt = $conn->prepare("SELECT COUNT(*) FROM student WHERE student_id = ?");
                        $checkStmt->execute([$student_id]);
                        $count = $checkStmt->fetchColumn();
                    } while ($count > 0);
                    
               
                    $dept_name = 'Computer Science';
                    $checkDeptStmt = $conn->prepare("SELECT COUNT(*) FROM department WHERE dept_name = ?");
                    $checkDeptStmt->execute([$dept_name]);
                    if ($checkDeptStmt->fetchColumn() == 0) {
                        // Insert the department if it doesn't exist
                        $insertDeptStmt = $conn->prepare("INSERT INTO department (dept_name, location) VALUES (?, ?)");
                        $insertDeptStmt->execute([$dept_name, 'Main Campus']);
                    }
                    
                    // Insert new student
                    $stmt = $conn->prepare("INSERT INTO student (student_id, email, name, dept_name) VALUES (?, ?, ?, ?)");
                    $stmt->execute([$student_id, $email, $name, $dept_name]);
                }
                
                // Commit transaction
                $conn->commit();
                
                echo json_encode([
                    'success' => true, 
                    'message' => 'Account created successfully',
                    'student_id' => $student_id,
                    'email' => $email,
                    'name' => $name,
                    'type' => $type,
                    'dept_name' => $dept_name
                ]);
            } catch (PDOException $e) {
                $conn->rollBack();
                error_log("Account creation error: " . $e->getMessage());
                echo json_encode(['success' => false, 'message' => 'Account creation failed: ' . $e->getMessage()]);
            }
        } 
        elseif ($action == 'login') {
            $email = $data['email'] ?? '';
            $password = $data['password'] ?? '';



            // Validate inputs
            if (empty($email) || empty($password)) {
                echo json_encode(['success' => false, 'message' => 'Email and password are required']);
                exit;
            }

            // Check if the email exists and password is correct
            $stmt = $conn->prepare("SELECT * FROM account WHERE email = ? AND password = ?");
            $stmt->execute([$email, $password]);

            if ($stmt->rowCount() > 0) {
                $account = $stmt->fetch(PDO::FETCH_ASSOC);
                
                if (strtolower($account['type']) == 'instructor') {
                    // Get instructor information
                    $stmt = $conn->prepare("SELECT i.instructor_id, i.instructor_name, i.title, i.dept_name FROM instructor i WHERE i.email = ?");
                    $stmt->execute([$email]);
                    
                    if ($stmt->rowCount() > 0) {
                        $instructor = $stmt->fetch(PDO::FETCH_ASSOC);
                        error_log("Instructor data found: " . json_encode($instructor));
                        
                        echo json_encode([
                            'success' => true,
                            'message' => 'Login successful',
                            'instructor_id' => $instructor['instructor_id'],
                            'email' => $account['email'],
                            'type' => strtolower($account['type']),
                            'name' => $instructor['instructor_name'],
                            'dept_name' => $instructor['dept_name'],
                            'title' => $instructor['title']
                        ]);
                    } else {
                        error_log("No instructor found for email: " . $email);
                        echo json_encode(['success' => false, 'message' => 'Instructor record not found']);
                    }
                } else {
                    // Get student information
                    $stmt = $conn->prepare("SELECT student_id, name, dept_name FROM student WHERE email = ?");
                    $stmt->execute([$email]);
                    
                    $student_id = null;
                    $name = null;
                    $dept_name = null;
                    
                    if ($stmt->rowCount() > 0) {
                        $student = $stmt->fetch(PDO::FETCH_ASSOC);
                        $student_id = $student['student_id'];
                        $name = $student['name'];
                        $dept_name = $student['dept_name'];
                    }
                    
                    echo json_encode([
                        'success' => true, 
                        'message' => 'Login successful',
                        'student_id' => $student_id,
                        'email' => $account['email'],
                        'type' => $account['type'],
                        'name' => $name,
                        'dept_name' => $dept_name
                    ]);
                }
            } else {
                echo json_encode(['success' => false, 'message' => 'Invalid email or password']);
            }
        }
        elseif ($action == 'register') {
            $student_id = $data['student_id'] ?? '';
            $course_id = $data['course_id'] ?? '';
            $section_id = $data['section_id'] ?? '';
            $semester = $data['semester'] ?? '';
            $year = $data['year'] ?? '';
            $join_waitlist = isset($data['join_waitlist']) ? $data['join_waitlist'] : false;

            // Validate inputs
            if (empty($student_id) || empty($course_id) || empty($section_id) || empty($semester) || empty($year)) {
                echo json_encode(['success' => false, 'message' => 'All fields are required']);
                exit;
            }

            try {
                // Check if section exists
                $section_sql = "SELECT capacity FROM section WHERE course_id = ? AND section_id = ? AND semester = ? AND year = ?";
                $section_stmt = $conn->prepare($section_sql);
                $section_stmt->execute([$course_id, $section_id, $semester, $year]);

                if ($section_stmt->rowCount() == 0) {
                    echo json_encode(['success' => false, 'message' => 'Section does not exist']);
                    exit;
                }

                // Check if already registered
                $check_sql = "SELECT 1 FROM take WHERE student_id = ? AND course_id = ? AND section_id = ? AND semester = ? AND year = ?";
                $check_stmt = $conn->prepare($check_sql);
                $check_stmt->execute([$student_id, $course_id, $section_id, $semester, $year]);

                if ($check_stmt->rowCount() > 0) {
                    echo json_encode(['success' => false, 'message' => 'You are already registered for this course section']);
                    exit;
                }

                // Check if already on waitlist
                $waitlist_check_sql = "SELECT 1 FROM waitlist WHERE student_id = ? AND course_id = ? AND section_id = ? AND semester = ? AND year = ?";
                $waitlist_check_stmt = $conn->prepare($waitlist_check_sql);
                $waitlist_check_stmt->execute([$student_id, $course_id, $section_id, $semester, $year]);

                if ($waitlist_check_stmt->rowCount() > 0) {
                    echo json_encode(['success' => false, 'message' => 'You are already on the waitlist for this course section']);
                    exit;
                }

                $section = $section_stmt->fetch(PDO::FETCH_ASSOC);
                $capacity = $section['capacity'];

                // Check current enrollment
                $enrollment_sql = "SELECT COUNT(*) as enrolled_count FROM take WHERE course_id = ? AND section_id = ? AND semester = ? AND year = ?";
                $enrollment_stmt = $conn->prepare($enrollment_sql);
                $enrollment_stmt->execute([$course_id, $section_id, $semester, $year]);
                $enrollment_result = $enrollment_stmt->fetch(PDO::FETCH_ASSOC);
                $enrolled_count = $enrollment_result['enrolled_count'];

                // Start transaction
                $conn->beginTransaction();
                //if ($enrolled_count >= $capacity || $join_waitlist) {
                if ($capacity == 0) {
                    // Get current waitlist count for this section
                    $waitlist_count_sql = "SELECT COUNT(*) as waitlist_count FROM waitlist WHERE course_id = ? AND section_id = ? AND semester = ? AND year = ?";
                    $waitlist_count_stmt = $conn->prepare($waitlist_count_sql);
                    $waitlist_count_stmt->execute([$course_id, $section_id, $semester, $year]);
                    $waitlist_count_result = $waitlist_count_stmt->fetch(PDO::FETCH_ASSOC);
                    $waitlist_count = $waitlist_count_result['waitlist_count'];
                    
                    // Add to waitlist with explicit position
                    $waitlist_sql = "INSERT INTO waitlist (student_id, course_id, section_id, semester, year, waitlist_position) VALUES (?, ?, ?, ?, ?, ?)";
                    $waitlist_stmt = $conn->prepare($waitlist_sql);
                    $waitlist_stmt->execute([$student_id, $course_id, $section_id, $semester, $year, $waitlist_count + 1]);
                    
                    $conn->commit();
                    echo json_encode(['success' => true, 'message' => 'Added to waitlist for course: ' . $course_id]);
                } else {
                    // Register for the course
                    $insert_sql = "INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES (?, ?, ?, ?, ?, NULL)";
                    $insert_stmt = $conn->prepare($insert_sql);
                    $insert_stmt->execute([$student_id, $course_id, $section_id, $semester, $year]);

                    // Reduce capacity by 1 when a student registers
                    $reduce_capacity_sql = "UPDATE section SET capacity = capacity - 1 WHERE course_id = ? AND section_id = ? AND semester = ? AND year = ?";
                    $reduce_capacity_stmt = $conn->prepare($reduce_capacity_sql);
                    $reduce_capacity_stmt->execute([$course_id, $section_id, $semester, $year]);

                    $conn->commit();
                    echo json_encode(['success' => true, 'message' => 'Successfully registered for course: ' . $course_id]);
                }
            } catch (PDOException $e) {
                if ($conn->inTransaction()) {
                    $conn->rollBack();
                }
                error_log("Registration error: " . $e->getMessage());
                echo json_encode(['success' => false, 'message' => 'Registration failed: ' . $e->getMessage()]);
            }
        }
        elseif ($action == 'drop') {
            $student_id = $data['student_id'] ?? '';
            $course_id = $data['course_id'] ?? '';
            $section_id = $data['section_id'] ?? '';
            $semester = $data['semester'] ?? '';
            $year = $data['year'] ?? '';

            // Validate inputs
            if (empty($student_id) || empty($course_id) || empty($section_id) || empty($semester) || empty($year)) {
                echo json_encode(['success' => false, 'message' => 'All fields are required']);
                exit;
            }

            try {
                // Check if registered
                $check_sql = "SELECT 1 FROM take WHERE student_id = ? AND course_id = ? AND section_id = ? AND semester = ? AND year = ?";
                $check_stmt = $conn->prepare($check_sql);
                $check_stmt->execute([$student_id, $course_id, $section_id, $semester, $year]);

                if ($check_stmt->rowCount() == 0) {
                    echo json_encode(['success' => false, 'message' => 'You are not registered for this course section']);
                    exit;
                }

                // Start transaction
                $conn->beginTransaction();

                // Drop the course
                $drop_sql = "DELETE FROM take WHERE student_id = ? AND course_id = ? AND section_id = ? AND semester = ? AND year = ?";
                $drop_stmt = $conn->prepare($drop_sql);
                $drop_stmt->execute([$student_id, $course_id, $section_id, $semester, $year]);

                // Increase capacity by 1 when a student drops
                $increase_capacity_sql = "UPDATE section SET capacity = capacity + 1 WHERE course_id = ? AND section_id = ? AND semester = ? AND year = ?";
                $increase_capacity_stmt = $conn->prepare($increase_capacity_sql);
                $increase_capacity_stmt->execute([$course_id, $section_id, $semester, $year]);

                // Check if there are students on the waitlist
                $waitlist_sql = "SELECT * FROM waitlist WHERE course_id = ? AND section_id = ? AND semester = ? AND year = ? ORDER BY waitlist_position ASC LIMIT 1";
                $waitlist_stmt = $conn->prepare($waitlist_sql);
                $waitlist_stmt->execute([$course_id, $section_id, $semester, $year]);

                if ($waitlist_stmt->rowCount() > 0) {
                    // Get the first student on the waitlist
                    $waitlist_student = $waitlist_stmt->fetch(PDO::FETCH_ASSOC);
                    $waitlist_student_id = $waitlist_student['student_id'];

                    // Remove the student from the waitlist
                    $remove_waitlist_sql = "DELETE FROM waitlist WHERE student_id = ? AND course_id = ? AND section_id = ? AND semester = ? AND year = ?";
                    $remove_waitlist_stmt = $conn->prepare($remove_waitlist_sql);
                    $remove_waitlist_stmt->execute([$waitlist_student_id, $course_id, $section_id, $semester, $year]);

                    // Register the student for the course
                    $register_sql = "INSERT INTO take (student_id, course_id, section_id, semester, year, grade) VALUES (?, ?, ?, ?, ?, NULL)";
                    $register_stmt = $conn->prepare($register_sql);
                    $register_stmt->execute([$waitlist_student_id, $course_id, $section_id, $semester, $year]);

                    // Decrease capacity by 1 for the newly registered student
                    $decrease_capacity_sql = "UPDATE section SET capacity = capacity - 1 WHERE course_id = ? AND section_id = ? AND semester = ? AND year = ?";
                    $decrease_capacity_stmt = $conn->prepare($decrease_capacity_sql);
                    $decrease_capacity_stmt->execute([$course_id, $section_id, $semester, $year]);

                    // Simple reordering of waitlist positions
                    $reorder_sql = "UPDATE waitlist SET waitlist_position = waitlist_position - 1 WHERE course_id = ? AND section_id = ? AND semester = ? AND year = ? AND waitlist_position > 1";
                    $reorder_stmt = $conn->prepare($reorder_sql);
                    $reorder_stmt->execute([$course_id, $section_id, $semester, $year]);

                    $conn->commit();
                    echo json_encode(['success' => true, 'message' => 'Successfully dropped course: ' . $course_id . ' and enrolled waitlisted student']);
                } else {
                    $conn->commit();
                    echo json_encode(['success' => true, 'message' => 'Successfully dropped course: ' . $course_id]);
                }
            } catch (PDOException $e) {
                if ($conn->inTransaction()) {
                    $conn->rollBack();
                }
                error_log("Drop course error: " . $e->getMessage());
                echo json_encode(['success' => false, 'message' => 'Failed to drop course: ' . $e->getMessage()]);
            }
        }
        // Action to get student registrations
        elseif ($action == 'get_registrations') {
            $student_id = $data['student_id'] ?? '';
            
            // Validate inputs
            if (empty($student_id)) {
                echo json_encode(['success' => false, 'message' => 'Student ID is required']);
                exit;
            }
            
            try {
                // Get all registrations for the student
                $sql = "SELECT * FROM take WHERE student_id = ?";
                $stmt = $conn->prepare($sql);
                $stmt->execute([$student_id]);
                
                $registrations = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                echo json_encode([
                    'success' => true,
                    'message' => 'Registrations retrieved successfully',
                    'registrations' => $registrations
                ]);
            } catch (PDOException $e) {
                error_log("Get registrations error: " . $e->getMessage());
                echo json_encode(['success' => false, 'message' => 'Failed to get registrations: ' . $e->getMessage()]);
            }
        }
        elseif ($action == 'get_waitlist') {
            $student_id = $data['student_id'] ?? '';
            
            if (empty($student_id)) {
                echo json_encode(['success' => false, 'message' => 'Student ID is required']);
                exit;
            }
            
            try {
                // Get all waitlist entries for the student
                $sql = "SELECT * FROM waitlist WHERE student_id = ?";
                $stmt = $conn->prepare($sql);
                $stmt->execute([$student_id]);
                
                $waitlist = $stmt->fetchAll(PDO::FETCH_ASSOC);
                
                echo json_encode([
                    'success' => true,
                    'message' => 'Waitlist entries retrieved successfully',
                    'waitlist' => $waitlist
                ]);
            } catch (PDOException $e) {
                error_log("Get waitlist error: " . $e->getMessage());
                echo json_encode(['success' => false, 'message' => 'Failed to get waitlist entries: ' . $e->getMessage()]);
            }
        }
    } 
    // Handle GET request to view all accounts in the database
    elseif ($method == 'GET') {
        $table = $_GET['table'] ?? '';
    
        if ($table == 'account') {
            $stmt = $conn->prepare("SELECT * FROM account");
            $stmt->execute();
            $accounts = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode(['success' => true, 'accounts' => $accounts]);
        }
    
        elseif ($table == 'section') {
            // Fetch available courses from section table with accurate waitlist count
            $sql = "SELECT s.*, 
                   (SELECT COUNT(w.student_id) 
                    FROM waitlist w 
                    WHERE w.course_id = s.course_id 
                    AND w.section_id = s.section_id 
                    AND w.semester = s.semester 
                    AND w.year = s.year) as waitlist_count 
                   FROM section s";
            
            error_log("Section query: " . $sql);
            
            $stmt = $conn->prepare($sql);
            $stmt->execute();
            $sections = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo json_encode(['success' => true, 'sections' => $sections]);
        }
    
        else {
            echo json_encode(['success' => false, 'message' => 'Invalid table requested']);
        }
    }
    
} catch(PDOException $e) {
    // Catch and log any errors
    error_log("Database error: " . $e->getMessage());
    echo json_encode(['success' => false, 'message' => $e->getMessage()]);
}
?>

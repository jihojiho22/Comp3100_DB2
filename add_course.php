<!DOCTYPE html>
<html>
<head>
    <title>Add new Course</title>
    <meta charset="UTF-8">
</head>
<body>
    <h1>Add new Course</h1>
  
    

    <h3>Add New Course</h3>
    <form action="add_course_db.php" method="post">
        <label for="course_id">Course ID:</label>
        <input type="text" name="course_id" required><br>

        <label for="course_name">Course Name:</label>
        <input type="text" name="course_name" required><br>

        <label for="credits">Credits:</label>
        <input type="number" name="credits" required><br>

        <button a href="add_course.php">Add Course</button>
    </form>
   

    <a href="dashboard.php"><button type="button">Back to Dashboard</button></a>
</body>
</html>
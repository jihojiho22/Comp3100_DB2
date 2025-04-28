# Course Registration Android App

This Android application is developed using **Android Studio** and **Kotlin**.  
It manages basic authentication with two user types: **Instructor** and **Student**.

## Features

- **Instructors** can:
  - View the sections they are teaching.
  - See the list of students enrolled in each section.

- **Students** can:
  - Register for available sections.
  - Join a waitlist if a section is full.
  - Get automatically enrolled when a spot opens (based on waitlist order).
  - View their registered courses.
  - Drop a course or remove themselves from a waitlist.

## How to Run

1. **Backend Setup:**
   - Place `api.php` into your XAMPP `htdocs` directory.  
     (Path: `xampp/htdocs/api.php`)
   - Create a new MySQL database named **DB2**.
   - Import `db2.sql` into the **DB2** database.

2. **Android App Setup:**
   - Make sure your Android app is configured to communicate with your local server (e.g., `http://localhost/api.php`).
   - Run the app through Android Studio.

## Team Members

- Nguyen Austin
- Jiho Lee
- Ryan Thomas

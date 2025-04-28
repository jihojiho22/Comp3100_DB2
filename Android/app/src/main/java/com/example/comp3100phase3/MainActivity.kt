package com.example.comp3100phase3

import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.text.KeyboardActions
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.platform.LocalContext
import com.example.comp3100phase3.ui.theme.COMP3100Phase3Theme
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.sql.DriverManager
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.launch
import com.google.gson.Gson
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.clickable
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import kotlinx.coroutines.delay

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            COMP3100Phase3Theme {
                var currentScreen by remember { mutableStateOf("login") }
                var currentUser by remember { mutableStateOf<User?>(null) }

                when (currentScreen) {
                    "login" -> LoginScreen(
                        onNavigateToCreateAccount = { currentScreen = "create" },
                        onNavigateToDashboard = { user ->
                            currentUser = user
                            currentScreen = "dashboard"
                        }
                    )
                    "create" -> CreateAccountScreen(
                        onNavigateToLogin = { currentScreen = "login" }
                    )
                    "dashboard" -> DashboardScreen(
                        onNavigateToLogin = {
                            currentUser = null
                            currentScreen = "login"
                        },
                        onNavigateToCourseRegistration = { currentScreen = "courseRegistration" },
                        onNavigateToMyCourses = { currentScreen = "myCourses" },
                        user = currentUser ?: User(
                            email = "",
                            type = "student",
                            student_id = null,
                            instructor_id = null,
                            name = null,
                            dept_name = null
                        )
                    )
                    "courseRegistration" -> CourseRegistrationScreen(
                        onNavigateToDashboard = { currentScreen = "dashboard" },
                        user = currentUser ?: User(
                            email = "",
                            type = "student",
                            student_id = null,
                            instructor_id = null,
                            name = null,
                            dept_name = null
                        )
                    )
                    "myCourses" -> MyCoursesScreen(
                        onNavigateToDashboard = { currentScreen = "dashboard" },
                        user = currentUser ?: User(
                            email = "",
                            type = "student",
                            student_id = null,
                            instructor_id = null,
                            name = null,
                            dept_name = null
                        )
                    )
                }
            }
        }
    }
}

@Composable
fun LoginScreen(
    onNavigateToCreateAccount: () -> Unit,
    onNavigateToDashboard: (User) -> Unit
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    val context = LocalContext.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Image(
            painter = painterResource(id = R.drawable.uml_logo),
            contentDescription = stringResource(id = R.string.uml_logo_desc),
            modifier = Modifier
                .height(200.dp)
                .width(200.dp)
        )

        Spacer(modifier = Modifier.height(24.dp))

        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") },
            modifier = Modifier.fillMaxWidth(),
            keyboardOptions = KeyboardOptions.Default.copy(
                imeAction = ImeAction.Next
            ),
            keyboardActions = KeyboardActions(
                onNext = { /* Handle next action */ }
            )
        )

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            modifier = Modifier.fillMaxWidth(),
            visualTransformation = PasswordVisualTransformation(),
            keyboardOptions = KeyboardOptions.Default.copy(
                imeAction = ImeAction.Done
            ),
            keyboardActions = KeyboardActions(
                onDone = {
                    if (email.isNotEmpty() && password.isNotEmpty()) {
                        onNavigateToDashboard(User(email, "student", null, null, null, null))
                        // Handle login

                    }
                }
            )
        )

        Spacer(modifier = Modifier.height(24.dp))

        // Display error message if any
        errorMessage?.let { message ->
            Text(
                text = message,
                color = MaterialTheme.colorScheme.error,
                modifier = Modifier.padding(vertical = 8.dp)
            )
        }

        Button(
            onClick = {
                if (email.isNotEmpty() && password.isNotEmpty()) {
                    isLoading = true
                    errorMessage = null

                    // Use coroutine scope for API call
                    CoroutineScope(Dispatchers.IO).launch {
                        try {
                            println("Building Retrofit client for login...")
                            val retrofit = Retrofit.Builder()
                                .baseUrl("http://10.0.2.2/")
                                .addConverterFactory(GsonConverterFactory.create())
                                .build()

                            val apiService = retrofit.create(ApiService::class.java)
                            println("Making login request with email: $email, password: $password")
                            val request = AccountRequest("login", email, "", password)
                            println("Login request: $request")
                            println("Login request JSON: ${Gson().toJson(request)}")

                            val response = apiService.login(request)
                            println("Login response code: ${response.code()}")
                            println("Login response body: ${response.body()}")
                            println("Login response error body: ${response.errorBody()?.string()}")

                            withContext(Dispatchers.Main) {
                                isLoading = false
                                if (response.isSuccessful) {
                                    val result = response.body()
                                    println("Login result: $result")
                                    if (result?.success == true) {
                                        Toast.makeText(context, "Login successful", Toast.LENGTH_SHORT).show()
                                        println("Login Response - student_id: ${result.student_id}")
                                        println("Login Response - instructor_id: ${result.instructor_id}")
                                        println("Login Response - email: ${result.email}")
                                        println("Login Response - name: ${result.name}")
                                        println("Login Response - type: ${result.type}")
                                        println("Login Response - dept_name: ${result.dept_name}")
                                        println("Login Response - title: ${result.title}")

                                        val user = User(
                                            email = result.email ?: email,
                                            type = result.type ?: "student",
                                            student_id = result.student_id,
                                            instructor_id = result.instructor_id,
                                            name = result.name,
                                            dept_name = result.dept_name
                                        )
                                        println("Created User - student_id: ${user.student_id}")
                                        println("Created User - instructor_id: ${user.instructor_id}")
                                        println("Created User - email: ${user.email}")
                                        println("Created User - name: ${user.name}")
                                        println("Created User - type: ${user.type}")
                                        println("Created User - dept_name: ${user.dept_name}")

                                        onNavigateToDashboard(user)
                                    } else {
                                        errorMessage = result?.message ?: "Login failed"
                                    }
                                } else {
                                    errorMessage = "Login failed: ${response.code()}"
                                }
                            }
                        } catch (e: Exception) {
                            println("Login error: ${e.message}")
                            e.printStackTrace()
                            withContext(Dispatchers.Main) {
                                isLoading = false
                                errorMessage = "Error: ${e.message}"
                            }
                        }
                    }
                } else {
                    errorMessage = "Please fill all fields"
                }
            },
            modifier = Modifier.fillMaxWidth(),
            enabled = !isLoading
        ) {
            if (isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(24.dp),
                    color = MaterialTheme.colorScheme.onPrimary
                )
            } else {
                Text(text = "Login")
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        TextButton(
            onClick = onNavigateToCreateAccount
        ) {
            Text(text = "Create Account")
        }
    }
}

@Composable
fun CreateAccountScreen(onNavigateToLogin: () -> Unit) {
    var email by remember { mutableStateOf("") }
    var name by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    var selectedDegree by remember { mutableStateOf("") }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    val context = LocalContext.current

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "Create Account",
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.padding(bottom = 24.dp)
        )

        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") },
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = name,
            onValueChange = { name = it },
            label = { Text("Name") },
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            modifier = Modifier.fillMaxWidth(),
            visualTransformation = PasswordVisualTransformation()
        )

        Spacer(modifier = Modifier.height(16.dp))

        OutlinedTextField(
            value = confirmPassword,
            onValueChange = { confirmPassword = it },
            label = { Text("Confirm Password") },
            modifier = Modifier.fillMaxWidth(),
            visualTransformation = PasswordVisualTransformation()
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Degree Selection Dropdown
        var expanded by remember { mutableStateOf(false) }
        val degrees = listOf("Undergraduate", "Master", "PhD")

        Box(modifier = Modifier.fillMaxWidth()) {
            OutlinedButton(
                onClick = { expanded = true },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(if (selectedDegree.isEmpty()) "Select Degree" else selectedDegree)
            }
            DropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false }
            ) {
                degrees.forEach { degree ->
                    DropdownMenuItem(
                        text = { Text(degree) },
                        onClick = {
                            selectedDegree = degree
                            expanded = false
                        }
                    )
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Display error message if any
        errorMessage?.let { message ->
            Text(
                text = message,
                color = MaterialTheme.colorScheme.error,
                modifier = Modifier.padding(vertical = 8.dp)
            )
        }

        Button(
            onClick = {
                if (email.isEmpty() || name.isEmpty() || password.isEmpty() || confirmPassword.isEmpty() || selectedDegree.isEmpty()) {
                    errorMessage = "Please fill all fields"
                    return@Button
                }

                if (password != confirmPassword) {
                    errorMessage = "Passwords do not match"
                    return@Button
                }

                isLoading = true
                errorMessage = null

                // Use coroutine scope for API call
                CoroutineScope(Dispatchers.IO).launch {
                    try {
                        val retrofit = Retrofit.Builder()
                            .baseUrl("http://10.0.2.2/")
                            .addConverterFactory(GsonConverterFactory.create())
                            .build()

                        val apiService = retrofit.create(ApiService::class.java)
                        val response = apiService.createAccount(
                            AccountRequest(
                                action = "create",
                                email = email,
                                name = name,
                                password = password,
                                type = "student",
                                dept_name = "Computer Science"
                            )
                        )

                        withContext(Dispatchers.Main) {
                            isLoading = false
                            if (response.isSuccessful) {
                                val result = response.body()
                                if (result?.success == true) {
                                    Toast.makeText(context, "Account created successfully", Toast.LENGTH_SHORT).show()
                                    onNavigateToLogin()
                                } else {
                                    errorMessage = result?.message ?: "Account creation failed"
                                }
                            } else {
                                errorMessage = "Account creation failed: ${response.code()}"
                            }
                        }
                    } catch (e: Exception) {
                        withContext(Dispatchers.Main) {
                            isLoading = false
                            errorMessage = "Error: ${e.message}"
                        }
                    }
                }
            },
            modifier = Modifier.fillMaxWidth(),
            enabled = !isLoading
        ) {
            if (isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(24.dp),
                    color = MaterialTheme.colorScheme.onPrimary
                )
            } else {
                Text(text = "Create Account")
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        TextButton(
            onClick = onNavigateToLogin
        ) {
            Text(text = "Back to Login")
        }
    }
}

@Preview(showBackground = true)
@Composable
fun PreviewLoginScreen() {
    COMP3100Phase3Theme {
        LoginScreen(onNavigateToCreateAccount = {}, onNavigateToDashboard = {})
    }
}

@Preview(showBackground = true)
@Composable
fun PreviewCreateAccountScreen() {
    COMP3100Phase3Theme {
        CreateAccountScreen(onNavigateToLogin = {})
    }
}

@Composable
fun DashboardScreen(
    onNavigateToLogin: () -> Unit,
    onNavigateToCourseRegistration: () -> Unit,
    onNavigateToMyCourses: () -> Unit,
    user: User
) {
    when (user.type?.lowercase()) {
        "instructor" -> InstructorDashboard(
            onNavigateToLogin = onNavigateToLogin,
            user = user,
            apiService = ApiService.api
        )
        else -> StudentDashboard(
            onNavigateToLogin = onNavigateToLogin,
            onNavigateToCourseRegistration = onNavigateToCourseRegistration,
            onNavigateToMyCourses = onNavigateToMyCourses,
            user = user
        )
    }
}

@Composable
fun StudentDashboard(
    onNavigateToLogin: () -> Unit,
    onNavigateToCourseRegistration: () -> Unit,
    onNavigateToMyCourses: () -> Unit,
    user: User
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "Student Dashboard",
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.padding(bottom = 24.dp)
        )

        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp)
        ) {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(
                    text = "Student Information",
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier.padding(bottom = 8.dp)
                )
                Text(
                    text = "Name: ${user.name ?: "N/A"}",
                    style = MaterialTheme.typography.bodyLarge
                )
                Text(
                    text = "Student ID: ${user.student_id ?: "N/A"}",
                    style = MaterialTheme.typography.bodyLarge
                )
                Text(
                    text = "Email: ${user.email}",
                    style = MaterialTheme.typography.bodyLarge
                )
                Text(
                    text = "Department: ${user.dept_name ?: "N/A"}",
                    style = MaterialTheme.typography.bodyLarge
                )
            }
        }

        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp)
                .clickable { onNavigateToMyCourses() }
        ) {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(
                    text = "My Courses",
                    style = MaterialTheme.typography.titleMedium
                )
                Text(
                    text = "View a list of all courses you have taken",
                    style = MaterialTheme.typography.bodyMedium
                )
            }
        }

        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp)
                .clickable { onNavigateToCourseRegistration() }
        ) {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(
                    text = "Course Registration",
                    style = MaterialTheme.typography.titleMedium
                )
                Text(
                    text = "Register for courses and view your schedule",
                    style = MaterialTheme.typography.bodyMedium
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        Button(
            onClick = onNavigateToLogin,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(text = "Logout")
        }
    }
}

@Composable
fun InstructorDashboard(
    onNavigateToLogin: () -> Unit,
    user: User,
    apiService: ApiService
) {
    var courses by remember { mutableStateOf<List<CourseRecord>>(emptyList()) }
    var isLoading by remember { mutableStateOf(true) }
    var errorMessage by remember { mutableStateOf<String?>(null) }

    var exampleInstructorId = "12345"

    LaunchedEffect(user.instructor_id) {
        try {
            user.instructor_id?.let { id ->
                val request = mapOf(
                    "action" to "get_instructor_records",
                    "instructor_id" to id
                )

                val response = apiService.getInstructorRecords(request)

                if (response.isSuccessful) {
                    val body = response.body()
                    if (body != null && body.success) {
                        courses = body.courses
                    } else {
                        errorMessage = body?.message ?: "Unknown error occurred"
                    }
                } else {
                    errorMessage = "Network request failed: ${response.code()}"
                }
            }
        } catch (e: Exception) {
            errorMessage = e.localizedMessage
        } finally {
            isLoading = false
        }
    }
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "Instructor Dashboard",
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.padding(bottom = 24.dp)
        )

        // Instructor Info Card
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("Instructor Information", style = MaterialTheme.typography.titleMedium, modifier = Modifier.padding(bottom = 8.dp))
                Text("Instructor ID: ${user.instructor_id ?: "N/A"}", style = MaterialTheme.typography.bodyLarge)
                Text("Name: ${user.name ?: "N/A"}", style = MaterialTheme.typography.bodyLarge)
                Text("Email: ${user.email}", style = MaterialTheme.typography.bodyLarge)
                Text("Department: ${user.dept_name ?: "N/A"}", style = MaterialTheme.typography.bodyLarge)
            }
        }

        // Teaching Records Card
        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp)
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text("View Teaching Records", style = MaterialTheme.typography.titleMedium)

                if (isLoading) {
                    CircularProgressIndicator(modifier = Modifier.padding(top = 16.dp))
                } else if (errorMessage != null) {
                    Text("Error loading courses: $errorMessage", color = MaterialTheme.colorScheme.error, modifier = Modifier.padding(top = 16.dp))
                } else if (courses.isEmpty()) {
                    Text("No courses found.", style = MaterialTheme.typography.bodyMedium, modifier = Modifier.padding(top = 8.dp))
                } else {
                    courses.forEach { course ->
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp)
                        ) {
                            Text(
                                text = "${course.course_id} - ${course.title} (${course.semester} ${course.year})",
                                style = MaterialTheme.typography.bodyMedium
                            )
                            Text(
                                text = course.description,
                                style = MaterialTheme.typography.bodySmall,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Logout Button
        Button(
            onClick = onNavigateToLogin,
            modifier = Modifier.fillMaxWidth()
        ) {
            Text(text = "Logout")
        }
    }
}


@Composable
fun CourseRegistrationScreen(
    onNavigateToDashboard: () -> Unit,
    user: User
) {
    var sections by remember { mutableStateOf<List<Section>>(emptyList()) }
    var registrations by remember { mutableStateOf<List<Registration>>(emptyList()) }
    var waitlistEntries by remember { mutableStateOf<List<WaitlistEntry>>(emptyList()) }
    var selectedSection by remember { mutableStateOf<Section?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var registrationSuccess by remember { mutableStateOf(false) }
    var dropSuccess by remember { mutableStateOf(false) }
    var waitlistSuccess by remember { mutableStateOf<String?>(null) }
    var selectedYear by remember { mutableStateOf<String?>(null) }
    var selectedSemester by remember { mutableStateOf<String?>(null) }
    val scope = rememberCoroutineScope()


    // Load sections and registrations when the screen is first displayed
    LaunchedEffect(Unit) {
        isLoading = true
        try {
            // Load available sections
            val sectionsResponse = ApiService.api.getAvailableSections("section")
            if (sectionsResponse.isSuccessful) {
                val result = sectionsResponse.body()
                if (result?.success == true) {
                    sections = result.sections
                } else {
                    errorMessage = result?.message ?: "Failed to load sections"
                }
            } else {
                errorMessage = "Failed to load sections: ${sectionsResponse.code()}"
            }

            // Load registrations if student_id is available
            if (user.student_id != null && !user.student_id.isNullOrEmpty()) {
                val registrationsResponse = ApiService.api.getRegistrations(mapOf(
                    "action" to "get_registrations",
                    "student_id" to (user.student_id ?: "")
                ))
                if (registrationsResponse.isSuccessful) {
                    val result = registrationsResponse.body()
                    if (result?.success == true) {
                        registrations = result.registrations ?: emptyList()
                    }
                }

                // Load waitlist entries
                val waitlistResponse = ApiService.api.getWaitlist(mapOf(
                    "action" to "get_waitlist",
                    "student_id" to user.student_id
                ))
                if (waitlistResponse.isSuccessful) {
                    val result = waitlistResponse.body()
                    if (result?.success == true) {
                        waitlistEntries = result.waitlist ?: emptyList()
                    }
                }
            }
        } catch (e: Exception) {
            errorMessage = "Error: ${e.message}"
        } finally {
            isLoading = false
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            text = "Course Registration",
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.padding(bottom = 16.dp)
        )

        // Year Selection Dropdown
        var expanded_year by remember { mutableStateOf(false) }
        val years = listOf("2020", "2021", "2022", "2023", "2024", "2025", "2026")

        Box(modifier = Modifier.fillMaxWidth()) {
            OutlinedButton(
                onClick = { expanded_year = true },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(if (selectedYear == null) "Select Year" else selectedYear.toString())
            }
            DropdownMenu(
                expanded = expanded_year,
                onDismissRequest = { expanded_year = false }
            ) {
                years.forEach { y ->
                    DropdownMenuItem(
                        text = { Text(y.toString()) },
                        onClick = {
                            selectedYear = y
                            expanded_year = false
                        }
                    )
                }
            }
        }

        var expanded_semester by remember { mutableStateOf(false) }
        val semesters = listOf("Fall", "Spring", "Winter")
        Box(modifier = Modifier.fillMaxWidth()) {
            OutlinedButton(
                onClick = { expanded_semester = true },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(if (selectedSemester == null) "Select Semester" else selectedSemester.toString())
            }
            DropdownMenu(
                expanded = expanded_semester,
                onDismissRequest = { expanded_semester = false }
            ) {
                semesters.forEach { s ->
                    DropdownMenuItem(
                        text = { Text(s) },
                        onClick = {
                            selectedSemester = s
                            expanded_semester = false
                        }
                    )
                }
            }
        }

        if (isLoading) {
            CircularProgressIndicator(
                modifier = Modifier
                    .size(50.dp)
                    .align(Alignment.CenterHorizontally)
            )
        } else if (errorMessage != null) {
            Text(
                text = errorMessage!!,
                color = MaterialTheme.colorScheme.error,
                modifier = Modifier.padding(vertical = 8.dp)
            )
        } else if (registrationSuccess) {
            Text(
                text = "Successfully registered for the course!",
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(vertical = 8.dp)
            )
        } else if (dropSuccess) {
            Text(
                text = "Successfully dropped the course!",
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(vertical = 8.dp)
            )
        } else if (waitlistSuccess != null) {
            Text(
                text = waitlistSuccess ?: "",
                color = MaterialTheme.colorScheme.primary,
                modifier = Modifier.padding(vertical = 8.dp)
            )
        }

        LazyColumn(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            items(sections) { section ->
                if (section.year == selectedYear && section.semester == selectedSemester) {
                // Check if the student is registered for this section
                val isRegistered = registrations.any { reg ->
                    reg.course_id == section.course_id &&
                            reg.section_id == section.section_id &&
                            reg.semester == section.semester &&
                            reg.year == section.year
                }

                // Check if the student is waitlisted for this section
                val isWaitlisted = waitlistEntries.any { entry ->
                    entry.course_id == section.course_id &&
                            entry.section_id == section.section_id &&
                            entry.semester == section.semester &&
                            entry.year == section.year
                }

                // Get waitlist position if waitlisted
                val waitlistPosition = if (isWaitlisted) {
                    waitlistEntries.find { entry ->
                        entry.course_id == section.course_id &&
                                entry.section_id == section.section_id &&
                                entry.semester == section.semester &&
                                entry.year == section.year
                    }?.waitlist_position
                } else null

                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 8.dp)
                        .clickable { selectedSection = section }
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(
                            text = "Course: ${section.course_id}",
                            style = MaterialTheme.typography.titleMedium
                        )
                        Text(
                            text = "Section: ${section.section_id}",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            text = "Semester: ${section.semester} ${section.year}",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            text = "Classroom: ${section.classroom_id}",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            text = "Instructor: ${section.instructor_id}",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            text = "Capacity: ${section.capacity}",
                            style = MaterialTheme.typography.bodyMedium
                        )

                        // Display waitlist information
                        if (section.waitlist_count != null && section.waitlist_count.toIntOrNull() ?: 0 > 0) {
                            Text(
                                text = "Students on Waitlist: ${section.waitlist_count.toIntOrNull() ?: 0}",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.primary,
                                modifier = Modifier.padding(top = 4.dp)
                            )
                        }

                        // Only show Drop button if the student is registered for this course
                        if (isRegistered && user.student_id != null && !user.student_id.isNullOrEmpty()) {
                            Button(
                                onClick = {
                                    if (user.student_id.isNullOrEmpty()) {
                                        errorMessage =
                                            "Student ID not available. Please contact support."
                                        return@Button
                                    }

                                    isLoading = true
                                    val request = CourseDropRequest(
                                        student_id = user.student_id,
                                        course_id = section.course_id,
                                        section_id = section.section_id,
                                        semester = section.semester,
                                        year = section.year
                                    )

                                    scope.launch {
                                        try {
                                            val response = ApiService.api.dropCourse(request)
                                            if (response.isSuccessful) {
                                                val result = response.body()
                                                if (result?.success == true) {
                                                    dropSuccess = true
                                                    errorMessage = null

                                                    // Reload sections and registrations after successful drop
                                                    delay(1000) // Wait for 1 second to show success message

                                                    // Reload sections
                                                    val sectionsResponse =
                                                        ApiService.api.getAvailableSections("section")
                                                    if (sectionsResponse.isSuccessful) {
                                                        val sectionsResult = sectionsResponse.body()
                                                        if (sectionsResult?.success == true) {
                                                            sections = sectionsResult.sections
                                                        }
                                                    }

                                                    // Reload registrations
                                                    val registrationsResponse =
                                                        ApiService.api.getRegistrations(
                                                            mapOf(
                                                                "action" to "get_registrations",
                                                                "student_id" to (user.student_id
                                                                    ?: "")
                                                            )
                                                        )
                                                    if (registrationsResponse.isSuccessful) {
                                                        val registrationsResult =
                                                            registrationsResponse.body()
                                                        if (registrationsResult?.success == true) {
                                                            registrations =
                                                                registrationsResult.registrations
                                                                    ?: emptyList()
                                                        }
                                                    }

                                                    // Reload waitlist entries
                                                    val waitlistResponse =
                                                        ApiService.api.getWaitlist(
                                                            mapOf(
                                                                "action" to "get_waitlist",
                                                                "student_id" to user.student_id
                                                            )
                                                        )
                                                    if (waitlistResponse.isSuccessful) {
                                                        val waitlistResult = waitlistResponse.body()
                                                        if (waitlistResult?.success == true) {
                                                            waitlistEntries =
                                                                waitlistResult.waitlist
                                                                    ?: emptyList()
                                                        }
                                                    }

                                                    // Reset success flags after reloading data
                                                    dropSuccess = false
                                                    registrationSuccess = false
                                                    waitlistSuccess = null

                                                    // Reload sections to update waitlist counts
                                                    try {
                                                        val sectionsResponse =
                                                            ApiService.api.getAvailableSections("section")
                                                        if (sectionsResponse.isSuccessful) {
                                                            val result = sectionsResponse.body()
                                                            if (result?.success == true) {
                                                                sections = result.sections
                                                            }
                                                        }
                                                    } catch (e: Exception) {
                                                        errorMessage =
                                                            "Error reloading sections: ${e.message}"
                                                    }
                                                } else {
                                                    errorMessage =
                                                        result?.message ?: "Failed to drop course"
                                                }
                                            } else {
                                                errorMessage =
                                                    "Failed to drop course: ${response.code()}"
                                            }
                                        } catch (e: Exception) {
                                            errorMessage = "Error: ${e.message}"
                                        } finally {
                                            isLoading = false
                                        }
                                    }
                                },
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(top = 8.dp)
                            ) {
                                Text("Drop Course")
                            }
                        }
                    }
                }
            }
            }
        }

        Spacer(modifier = Modifier.height(16.dp))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Button(
                onClick = onNavigateToDashboard,
                modifier = Modifier
                    .weight(1f)
                    .padding(end = 8.dp)
            ) {
                Text(text = "Back to Dashboard")
            }

            if (selectedSection != null && !registrationSuccess && !dropSuccess && waitlistSuccess == null) {
                // Check if the selected section is already registered
                val isAlreadyRegistered = registrations.any { reg ->
                    reg.course_id == selectedSection?.course_id &&
                            reg.section_id == selectedSection?.section_id &&
                            reg.semester == selectedSection?.semester &&
                            reg.year == selectedSection?.year
                }

                // Check if the selected section is already waitlisted
                val isAlreadyWaitlisted = waitlistEntries.any { entry ->
                    entry.course_id == selectedSection?.course_id &&
                            entry.section_id == selectedSection?.section_id &&
                            entry.semester == selectedSection?.semester &&
                            entry.year == selectedSection?.year
                }

                // Only show Register/Join Waitlist button if not already registered or waitlisted
                if (!isAlreadyRegistered && !isAlreadyWaitlisted) {
                    Button(
                        onClick = {
                            if (user.student_id.isNullOrEmpty()) {
                                errorMessage = "Student ID not available. Please contact support."
                                return@Button
                            }

                            isLoading = true
                            val request = CourseRegisterRequest(
                                student_id = user.student_id,
                                course_id = selectedSection?.course_id ?: "",
                                section_id = selectedSection?.section_id ?: "",
                                semester = selectedSection?.semester ?: "",
                                year = selectedSection?.year ?: "",
                                join_waitlist = selectedSection?.capacity?.toIntOrNull() == 0
                            )

                            scope.launch {
                                try {
                                    val response = ApiService.api.registerForCourse(request)
                                    if (response.isSuccessful) {
                                        val result = response.body()
                                        if (result?.success == true) {
                                            if (request.join_waitlist) {
                                                waitlistSuccess = "Successfully added to the waitlist!"
                                            } else {
                                                registrationSuccess = true
                                            }
                                            errorMessage = null

                                            // Reload sections and registrations after successful registration/waitlist
                                            delay(1000) // Wait for 1 second to show success message

                                            // Reload sections
                                            val sectionsResponse = ApiService.api.getAvailableSections("section")
                                            if (sectionsResponse.isSuccessful) {
                                                val sectionsResult = sectionsResponse.body()
                                                if (sectionsResult?.success == true) {
                                                    sections = sectionsResult.sections
                                                }
                                            }

                                            // Reload registrations
                                            val registrationsResponse = ApiService.api.getRegistrations(mapOf(
                                                "action" to "get_registrations",
                                                "student_id" to (user.student_id ?: "")
                                            ))
                                            if (registrationsResponse.isSuccessful) {
                                                val registrationsResult = registrationsResponse.body()
                                                if (registrationsResult?.success == true) {
                                                    registrations = registrationsResult.registrations ?: emptyList()
                                                }
                                            }

                                            // Reload waitlist entries
                                            val waitlistResponse = ApiService.api.getWaitlist(mapOf(
                                                "action" to "get_waitlist",
                                                "student_id" to (user.student_id ?: "")
                                            ))
                                            if (waitlistResponse.isSuccessful) {
                                                val waitlistResult = waitlistResponse.body()
                                                if (waitlistResult?.success == true) {
                                                    waitlistEntries = waitlistResult.waitlist ?: emptyList()
                                                }
                                            }

                                            // Reset success flags after reloading data
                                            dropSuccess = false
                                            registrationSuccess = false
                                            waitlistSuccess = null

                                            // Reload sections to update waitlist counts
                                            try {
                                                val sectionsResponse = ApiService.api.getAvailableSections("section")
                                                if (sectionsResponse.isSuccessful) {
                                                    val result = sectionsResponse.body()
                                                    if (result?.success == true) {
                                                        sections = result.sections
                                                    }
                                                }
                                            } catch (e: Exception) {
                                                errorMessage = "Error reloading sections: ${e.message}"
                                            }
                                        } else {
                                            errorMessage = result?.message ?: "Registration failed"
                                        }
                                    } else {
                                        errorMessage = "Registration failed: ${response.code()}"
                                    }
                                } catch (e: Exception) {
                                    errorMessage = "Error: ${e.message}"
                                } finally {
                                    isLoading = false
                                }
                            }
                        },
                        modifier = Modifier
                            .weight(1f)
                            .padding(start = 8.dp)
                    ) {
                        Text(text = if (selectedSection?.capacity?.toIntOrNull() == 0) "Join Waitlist" else "Register")
                    }
                }
            }
        }
    }
}

@Composable
fun MyCoursesScreen(
    onNavigateToDashboard: () -> Unit,
    user: User
) {
    //var sections by remember { mutableStateOf<List<Section>>(emptyList()) }
    var registrations by remember { mutableStateOf<List<Registration>>(emptyList()) }
    var waitlistEntries by remember { mutableStateOf<List<WaitlistEntry>>(emptyList()) }
    /*var selectedSection by remember { mutableStateOf<Section?>(null) }*/
    var isLoading by remember { mutableStateOf(false) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    var registrationSuccess by remember { mutableStateOf(false) }
    var dropSuccess by remember { mutableStateOf(false) }
    /*var waitlistSuccess by remember { mutableStateOf<String?>(null) }*/
    val scope = rememberCoroutineScope()
    var selectedYear by remember { mutableStateOf<String?>(null) }
    var selectedSemester by remember { mutableStateOf<String?>(null) }



    // Load sections and registrations when the screen is first displayed
    LaunchedEffect(Unit) {
        isLoading = true
        try {
            // Load registrations if student_id is available
            if (user.student_id != null && !user.student_id.isNullOrEmpty()) {
                val registrationsResponse = ApiService.api.getRegistrations(mapOf(
                    "action" to "get_registrations",
                    "student_id" to (user.student_id ?: "")
                ))
                if (registrationsResponse.isSuccessful) {
                    val result = registrationsResponse.body()
                    if (result?.success == true) {
                        registrations = result.registrations ?: emptyList()
                    }
                }


                val waitlistResponse = ApiService.api.getWaitlist(mapOf(
                    "action" to "get_waitlist",
                    "student_id" to user.student_id
                ))
                if (waitlistResponse.isSuccessful) {
                    val waitlistResult = waitlistResponse.body()
                    if (waitlistResult?.success == true) {
                        waitlistEntries = waitlistResult.waitlist ?: emptyList()
                    }
                }
            }
        } catch (e: Exception) {
            errorMessage = "Error: ${e.message}"
        } finally {
            isLoading = false
        }
    }


    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp)
    ) {
        Text(
            text = "My Courses",
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.padding(bottom = 16.dp)
        )

        // Year Selection Dropdown
        var expanded_year by remember { mutableStateOf(false) }
        val years = listOf("2020", "2021", "2022", "2023", "2024", "2025", "2026")

        Box(modifier = Modifier.fillMaxWidth()) {
            OutlinedButton(
                onClick = { expanded_year = true },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(if (selectedYear == null) "Select Year" else selectedYear.toString())
            }
            DropdownMenu(
                expanded = expanded_year,
                onDismissRequest = { expanded_year = false }
            ) {
                years.forEach { y ->
                    DropdownMenuItem(
                        text = { Text(y.toString()) },
                        onClick = {
                            selectedYear = y
                            expanded_year = false
                        }
                    )
                }
            }
        }

        var expanded_semester by remember { mutableStateOf(false) }
        val semesters = listOf("Fall", "Spring", "Winter")
        Box(modifier = Modifier.fillMaxWidth()) {
            OutlinedButton(
                onClick = { expanded_semester = true },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(if (selectedSemester == null) "Select Semester" else selectedSemester.toString())
            }
            DropdownMenu(
                expanded = expanded_semester,
                onDismissRequest = { expanded_semester = false }
            ) {
                semesters.forEach { s ->
                    DropdownMenuItem(
                        text = { Text(s) },
                        onClick = {
                            selectedSemester = s
                            expanded_semester = false
                        }
                    )
                }
            }
        }

        if (isLoading) {
            CircularProgressIndicator(
                modifier = Modifier
                    .size(50.dp)
                    .align(Alignment.CenterHorizontally)
            )
        } else if (errorMessage != null) {
            Text(
                text = errorMessage!!,
                color = MaterialTheme.colorScheme.error,
                modifier = Modifier.padding(vertical = 8.dp)
            )
        }


        LazyColumn(
            modifier = Modifier
                .weight(1f)
                .fillMaxWidth()
        ) {
            items(registrations) { section ->
                if (section.year == selectedYear && section.semester == selectedSemester) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 8.dp)
                    //.clickable { selectedSection = section }
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text(
                            text = "Course: ${section.course_id}",
                            style = MaterialTheme.typography.titleMedium
                        )
                        Text(
                            text = "Section: ${section.section_id}",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            text = "Semester: ${section.semester} ${section.semester}",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            text = "Year: ${section.year}",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            text = "Grade: ${section.grade}",
                            style = MaterialTheme.typography.bodyMedium
                        )


                        Button(
                            onClick = {
                                if (user.student_id.isNullOrEmpty()) {
                                    errorMessage =
                                        "Student ID not available. Please contact support."
                                    return@Button
                                }


                                isLoading = true
                                val request = CourseDropRequest(
                                    student_id = user.student_id,
                                    course_id = section.course_id,
                                    section_id = section.section_id,
                                    semester = section.semester,
                                    year = section.year
                                )


                                scope.launch {
                                    try {
                                        val response = ApiService.api.dropCourse(request)
                                        if (response.isSuccessful) {
                                            val result = response.body()
                                            if (result?.success == true) {
                                                dropSuccess = true
                                                errorMessage = null


                                                // Reload sections and registrations after successful drop
                                                delay(1000) // Wait for 1 second to show success message


                                                // Reload registrations
                                                val registrationsResponse =
                                                    ApiService.api.getRegistrations(
                                                        mapOf(
                                                            "action" to "get_registrations",
                                                            "student_id" to (user.student_id ?: "")
                                                        )
                                                    )
                                                if (registrationsResponse.isSuccessful) {
                                                    val registrationsResult =
                                                        registrationsResponse.body()
                                                    if (registrationsResult?.success == true) {
                                                        registrations =
                                                            registrationsResult.registrations
                                                                ?: emptyList()
                                                    }
                                                }
                                                val waitlistResponse = ApiService.api.getWaitlist(
                                                    mapOf(
                                                        "action" to "get_waitlist",
                                                        "student_id" to user.student_id
                                                    )
                                                )
                                                if (waitlistResponse.isSuccessful) {
                                                    val waitlistResult = waitlistResponse.body()
                                                    if (waitlistResult?.success == true) {
                                                        waitlistEntries =
                                                            waitlistResult.waitlist ?: emptyList()
                                                    }
                                                }


                                                // Reset success flags after reloading data
                                                dropSuccess = false
                                                registrationSuccess = false
                                                //waitlistSuccess = null
                                            } else {
                                                errorMessage =
                                                    result?.message ?: "Failed to drop course"
                                            }
                                        } else {
                                            errorMessage =
                                                "Failed to drop course: ${response.code()}"
                                        }
                                    } catch (e: Exception) {
                                        errorMessage = "Error: ${e.message}"
                                    } finally {
                                        isLoading = false
                                    }
                                }
                            },
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(top = 8.dp)
                        ) {
                            Text("Drop Course")
                        }
                    }
                }
            }
            }

            items(waitlistEntries) { waitlist ->
                if (waitlist.year == selectedYear && waitlist.semester == selectedSemester) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(vertical = 8.dp)
                    //.clickable { selectedSection = section }
                ) {
                    Column(
                        modifier = Modifier.padding(16.dp)
                    ) {
                        Text (
                            text = "WaitListed",
                            style = MaterialTheme.typography.titleLarge
                        )
                        Text(
                            text = "Course: ${waitlist.course_id}",
                            style = MaterialTheme.typography.titleMedium
                        )
                        Text(
                            text = "Section: ${waitlist.section_id}",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            text = "Semester: ${waitlist.semester} ${waitlist.semester}",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            text = "Year: ${waitlist.year}",
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Text(
                            text = "Position: ${waitlist.waitlist_position}",
                            style = MaterialTheme.typography.bodyMedium
                        )


                        Button(
                            onClick = {
                                if (user.student_id.isNullOrEmpty()) {
                                    errorMessage =
                                        "Student ID not available. Please contact support."
                                    return@Button
                                }


                                isLoading = true
                                val request = WaitlistDropRequest(
                                    student_id = user.student_id,
                                    course_id = waitlist.course_id,
                                    section_id = waitlist.section_id,
                                    semester = waitlist.semester,
                                    year = waitlist.year,
                                    waitlist_position=waitlist.waitlist_position
                                )


                                scope.launch {
                                    try {
                                        val response = ApiService.api.dropWaitlist(request)
                                        if (response.isSuccessful) {
                                            val result = response.body()
                                            if (result?.success == true) {
                                                dropSuccess = true
                                                errorMessage = null


                                                // Reload sections and registrations after successful drop
                                                delay(1000) // Wait for 1 second to show success message


                                                // Reload registrations
                                                val registrationsResponse =
                                                    ApiService.api.getRegistrations(
                                                        mapOf(
                                                            "action" to "get_registrations",
                                                            "student_id" to (user.student_id ?: "")
                                                        )
                                                    )
                                                if (registrationsResponse.isSuccessful) {
                                                    val registrationsResult =
                                                        registrationsResponse.body()
                                                    if (registrationsResult?.success == true) {
                                                        registrations =
                                                            registrationsResult.registrations
                                                                ?: emptyList()
                                                    }
                                                }
                                                val waitlistResponse = ApiService.api.getWaitlist(
                                                    mapOf(
                                                        "action" to "get_waitlist",
                                                        "student_id" to user.student_id
                                                    )
                                                )
                                                if (waitlistResponse.isSuccessful) {
                                                    val waitlistResult = waitlistResponse.body()
                                                    if (waitlistResult?.success == true) {
                                                        waitlistEntries =
                                                            waitlistResult.waitlist ?: emptyList()
                                                    }
                                                }


                                                // Reset success flags after reloading data
                                                dropSuccess = false
                                                registrationSuccess = false
                                                //waitlistSuccess = null
                                            } else {
                                                errorMessage =
                                                    result?.message ?: "Failed to drop course"
                                            }
                                        } else {
                                            errorMessage =
                                                "Failed to drop course: ${response.code()}"
                                        }
                                    } catch (e: Exception) {
                                        errorMessage = "Error: ${e.message}"
                                    } finally {
                                        isLoading = false
                                    }
                                }
                            },
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(top = 8.dp)
                        ) {
                            Text("Drop From Waitlist")
                        }
                    }
                }
                }
            }
        }


        Spacer(modifier = Modifier.height(16.dp))


        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Button(
                onClick = onNavigateToDashboard,
                modifier = Modifier
                    .weight(1f)
                    .padding(end = 8.dp)
            ) {
                Text(text = "Back to Dashboard")
            }
        }
    }
}

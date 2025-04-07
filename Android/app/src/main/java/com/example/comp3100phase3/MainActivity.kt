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

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            COMP3100Phase3Theme {
                var currentScreen by remember { mutableStateOf("login") }
                
                when (currentScreen) {
                    "login" -> LoginScreen(
                        onNavigateToCreateAccount = { currentScreen = "create" },
                        onNavigateToDashboard = { currentScreen = "dashboard" }
                    )
                    "create" -> CreateAccountScreen(
                        onNavigateToLogin = { currentScreen = "login" }
                    )
                    "dashboard" -> DashboardScreen(
                        onNavigateToLogin = { currentScreen = "login" }
                    )
                }
            }
        }
    }
}

@Composable
fun LoginScreen(
    onNavigateToCreateAccount: () -> Unit,
    onNavigateToDashboard: () -> Unit
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
                            val request = AccountRequest("login", email, password)
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
                                        onNavigateToDashboard()
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
                if (email.isEmpty() || password.isEmpty() || confirmPassword.isEmpty() || selectedDegree.isEmpty()) {
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
                            AccountRequest("create", email, password, selectedDegree)
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
fun DashboardScreen(onNavigateToLogin: () -> Unit) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        Text(
            text = "Dashboard",
            style = MaterialTheme.typography.headlineMedium,
            modifier = Modifier.padding(bottom = 24.dp)
        )
        

        Text(
            text = "Welcome to your dashboard!",
            style = MaterialTheme.typography.bodyLarge,
            modifier = Modifier.padding(bottom = 16.dp)
        )
        

        Card(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp)
        ) {
            Column(
                modifier = Modifier.padding(16.dp)
            ) {
                Text(
                    text = "View Course",
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

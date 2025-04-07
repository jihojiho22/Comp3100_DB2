package com.example.comp3100phase3

import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST

data class StudentIdsResponse(
    val student_ids: List<String>
)

data class AccountResponse(
    val success: Boolean,
    val message: String,
    val user: User? = null
)

data class User(
    val email: String,
    val password: String,
    val type: String
)

data class AccountRequest(
    val action: String,
    val email: String,
    val password: String,
    val type: String? = null
)

interface ApiService {
    @POST("account_api.php")
    suspend fun createAccount(@Body request: AccountRequest): Response<AccountResponse>
    
    @POST("account_api.php")
    suspend fun login(@Body request: AccountRequest): Response<AccountResponse>
} 
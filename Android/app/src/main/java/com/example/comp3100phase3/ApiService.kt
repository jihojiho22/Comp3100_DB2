// ApiService.kt
package com.example.comp3100phase3

import retrofit2.Response
import retrofit2.http.Body
import retrofit2.http.GET
import retrofit2.http.POST
import retrofit2.http.Query
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory

// -------- Responses --------
data class ApiResponse(
    val success: Boolean,
    val message: String
)

data class AccountResponse(
    val success: Boolean,
    val message: String,
    val student_id: String? = null,
    val instructor_id: String? = null,
    val name: String? = null,
    val email: String? = null,
    val type: String? = null,
    val dept_name: String? = null,
    val title: String? = null
)

// -------- Data Models --------
data class User(
    val email: String,
    val type: String,
    val student_id: String?,
    val instructor_id: String?,
    val name: String?,
    val dept_name: String?
)

data class AccountRequest(
    val action: String,
    val email: String,
    val name: String,
    val password: String,
    val type: String = "student",
    val dept_name: String? = null
)

data class RegisterRequest(
    val action: String = "register",
    val student_id: String,
    val course_id: String,
    val section_id: String,
    val semester: String,
    val year: String
)

// -------- Section Response --------
data class Section(
    val course_id: String,
    val section_id: String,
    val semester: String,
    val year: String,
    val instructor_id: String,
    val classroom_id: String,
    val time_slot_id: String,
    val course_name: String? = null,
    val instructor_name: String? = null,
    val capacity: String,
    val waitlist_count: String? = "0"
)

data class SectionsResponse(
    val success: Boolean,
    val message: String?,
    val sections: List<Section>
)

data class CourseRegisterRequest(
    val action: String = "register",
    val student_id: String,
    val course_id: String,
    val section_id: String,
    val semester: String,
    val year: String,
    val join_waitlist: Boolean = false
)

data class CourseDropRequest(
    val action: String = "drop",
    val student_id: String,
    val course_id: String,
    val section_id: String,
    val semester: String,
    val year: String
)

data class WaitlistDropRequest(
    val action: String = "drop_waitlist",
    val student_id: String,
    val course_id: String,
    val section_id: String,
    val semester: String,
    val year: String,
    val waitlist_position: Int
)

data class CancelWaitlistRequest(
    val action: String = "cancel_waitlist",
    val student_id: String,
    val course_id: String,
    val section_id: String,
    val semester: String,
    val year: String
)

data class Registration(
    val student_id: String,
    val course_id: String,
    val section_id: String,
    val semester: String,
    val year: String,
    val grade: String?
)

data class WaitlistEntry(
    val student_id: String,
    val course_id: String,
    val section_id: String,
    val semester: String,
    val year: String,
    val waitlist_position: Int,
    val waitlist_date: String
)

data class WaitlistResponse(
    val success: Boolean,
    val message: String? = null,
    val waitlist: List<WaitlistEntry>? = null
)

data class RegistrationsResponse(
    val success: Boolean,
    val message: String? = null,
    val registrations: List<Registration>? = null
)

// -------- Instructor Registration Response --------
data class InstructorRecordsResponse(
    val instructor_id: String,
    val success: Boolean,
    val message: String,
    val courses: List<CourseRecord> = emptyList()
)

data class CourseRecord(
    val course_id: String,
    val title: String,
    val description: String,
    val section_id: String,
    val semester: String,
    val year: String
)

// -------- API Interface --------
interface ApiService {
    @POST("api.php")
    suspend fun createAccount(@Body request: AccountRequest): Response<AccountResponse>

    @POST("api.php")
    suspend fun login(@Body request: AccountRequest): Response<AccountResponse>

    @GET("api.php")
    suspend fun getAvailableSections(@Query("table") table: String): Response<SectionsResponse>

    @POST("api.php")
    suspend fun registerForCourse(@Body request: CourseRegisterRequest): Response<ApiResponse>
    
    @POST("api.php")
    suspend fun dropCourse(@Body request: CourseDropRequest): Response<ApiResponse>
    
    @POST("api.php")
    suspend fun dropWaitlist(@Body request: WaitlistDropRequest): Response<ApiResponse>

    @POST("api.php")
    suspend fun getRegistrations(@Body request: Map<String, String>): Response<RegistrationsResponse>
    
    @POST("api.php")
    suspend fun getWaitlist(@Body request: Map<String, String>): Response<WaitlistResponse>
    
    @POST("api.php")
    suspend fun cancelWaitlist(@Body request: CancelWaitlistRequest): ApiResponse

    @POST("api.php")
    suspend fun getInstructorRecords(@Body request: Map<String, String>): Response<InstructorRecordsResponse>
    companion object {
        val api: ApiService by lazy {
            Retrofit.Builder()
                .baseUrl("http://10.0.2.2/")
                .addConverterFactory(GsonConverterFactory.create())
                .build()
                .create(ApiService::class.java)
        }
    }
}

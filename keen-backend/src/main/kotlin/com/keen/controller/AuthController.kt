package com.keen.controller

import com.keen.dto.LoginRequest
import com.keen.dto.RegisterRequest
import com.keen.dto.AuthResponse
import com.keen.service.UserService
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/auth")
class AuthController(
    private val userService: UserService
) {
    
    @PostMapping("/register")
    fun register(@RequestBody request: RegisterRequest): ResponseEntity<Any> {
        return try {
            val response = userService.register(request)
            ResponseEntity.ok(response)
        } catch (ex: Exception) {
            ResponseEntity.badRequest().body(mapOf("message" to (ex.message ?: "Registration failed")))
        }
    }
    
    @PostMapping("/login")
    fun login(@RequestBody request: LoginRequest): ResponseEntity<Any> {
        return try {
            val response = userService.login(request)
            ResponseEntity.ok(response)
        } catch (ex: Exception) {
            ResponseEntity.badRequest().body(mapOf("message" to "Invalid email or password"))
        }
    }
}

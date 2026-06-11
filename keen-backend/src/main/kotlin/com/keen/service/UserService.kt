package com.keen.service

import com.keen.dto.LoginRequest
import com.keen.dto.RegisterRequest
import com.keen.dto.AuthResponse
import com.keen.dto.UserResponse
import com.keen.entity.User
import com.keen.entity.UserRole
import com.keen.repository.UserRepository
import com.keen.security.JwtProvider
import org.springframework.security.authentication.AuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service

@Service
class UserService(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder,
    private val authenticationManager: AuthenticationManager,
    private val jwtProvider: JwtProvider
) {
    
    fun register(request: RegisterRequest): AuthResponse {
        if (userRepository.findByEmail(request.email).isPresent) {
            throw IllegalArgumentException("Email already exists")
        }
        
        val user = User(
            email = request.email,
            password = passwordEncoder.encode(request.password),
            firstName = request.firstName,
            lastName = request.lastName,
            role = UserRole.USER
        )
        
        val savedUser = userRepository.save(user)
        val token = jwtProvider.generateTokenFromUsername(savedUser.email)
        
        return AuthResponse(
            token = token,
            user = savedUser.toUserResponse()
        )
    }
    
    fun login(request: LoginRequest): AuthResponse {
        val authentication = authenticationManager.authenticate(
            UsernamePasswordAuthenticationToken(request.email, request.password)
        )
        
        val token = jwtProvider.generateToken(authentication)
        val user = userRepository.findByEmail(request.email).orElseThrow()
        
        return AuthResponse(
            token = token,
            user = user.toUserResponse()
        )
    }
    
    private fun User.toUserResponse() = UserResponse(
        id = this.id,
        email = this.email,
        firstName = this.firstName,
        lastName = this.lastName,
        role = this.role.name
    )
}

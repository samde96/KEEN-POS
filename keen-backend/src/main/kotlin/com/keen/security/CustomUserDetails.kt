package com.keen.security

import com.keen.entity.User
import org.springframework.security.core.GrantedAuthority
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.UserDetails

class CustomUserDetails(
    private val user: User
) : UserDetails {
    
    override fun getAuthorities(): Collection<GrantedAuthority> {
        return listOf(SimpleGrantedAuthority("ROLE_${user.role.name}"))
    }
    
    override fun getPassword(): String = user.password
    
    override fun getUsername(): String = user.email
    
    override fun isAccountNonExpired(): Boolean = true
    
    override fun isAccountNonLocked(): Boolean = true
    
    override fun isCredentialsNonExpired(): Boolean = true
    
    override fun isEnabled(): Boolean = user.isActive
    
    fun getId(): Long = user.id
    
    fun getFirstName(): String = user.firstName
    
    fun getLastName(): String = user.lastName
}

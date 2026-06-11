package com.keen.repository

import com.keen.entity.Product
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository

@Repository
interface ProductRepository : JpaRepository<Product, Long> {
    fun findByCategory(category: String, pageable: Pageable): Page<Product>
    
    fun findByIsActive(isActive: Boolean, pageable: Pageable): Page<Product>
    
    @Query(
        """
        SELECT p FROM Product p
        WHERE LOWER(p.name) LIKE LOWER(CONCAT('%', :searchTerm, '%'))
           OR LOWER(p.description) LIKE LOWER(CONCAT('%', :searchTerm, '%'))
           OR LOWER(p.category) LIKE LOWER(CONCAT('%', :searchTerm, '%'))
           OR LOWER(COALESCE(p.brand, '')) LIKE LOWER(CONCAT('%', :searchTerm, '%'))
        """
    )
    fun searchProducts(searchTerm: String, pageable: Pageable): Page<Product>

    @Query("SELECT DISTINCT p.category FROM Product p WHERE p.category <> '' ORDER BY p.category")
    fun findDistinctCategories(): List<String>

    @Query("SELECT DISTINCT p.brand FROM Product p WHERE p.brand IS NOT NULL AND p.brand <> '' ORDER BY p.brand")
    fun findDistinctBrands(): List<String>

    @Query("SELECT DISTINCT size FROM Product p JOIN p.sizes size WHERE size <> '' ORDER BY size")
    fun findDistinctSizes(): List<String>

    @Query("SELECT DISTINCT color FROM Product p JOIN p.colors color WHERE color <> '' ORDER BY color")
    fun findDistinctColors(): List<String>
}

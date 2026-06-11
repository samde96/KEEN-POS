package com.keen.entity

import jakarta.persistence.*
import java.math.BigDecimal
import java.time.LocalDateTime

@Entity
@Table(name = "products")
data class Product(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(nullable = false)
    val name: String = "",

    @Column(columnDefinition = "TEXT")
    val description: String = "",

    @Column(nullable = false)
    val category: String = "",

    @Column
    val brand: String? = "",

    @Column(nullable = false)
    val price: BigDecimal = BigDecimal.ZERO,

    @Column(nullable = false, columnDefinition = "DECIMAL(19,2) DEFAULT 0")
    val costPrice: BigDecimal = BigDecimal.ZERO,

    @Column(nullable = false)
    val stockQuantity: Int = 0,

    @ElementCollection
    @CollectionTable(name = "product_sizes", joinColumns = [JoinColumn(name = "product_id")])
    @Column(name = "size")
    val sizes: MutableList<String> = mutableListOf(),

    @ElementCollection
    @CollectionTable(name = "product_colors", joinColumns = [JoinColumn(name = "product_id")])
    @Column(name = "color")
    val colors: MutableList<String> = mutableListOf(),

    @Column(columnDefinition = "TEXT")
    val imageUrl: String = "",

    @ElementCollection
    @CollectionTable(name = "product_photos", joinColumns = [JoinColumn(name = "product_id")])
    @Column(name = "photo_url", columnDefinition = "TEXT")
    val imageUrls: MutableList<String> = mutableListOf(),

    @Column(nullable = false)
    val isActive: Boolean = true,

    @Column(nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),

    @Column(nullable = false)
    val updatedAt: LocalDateTime = LocalDateTime.now()
)

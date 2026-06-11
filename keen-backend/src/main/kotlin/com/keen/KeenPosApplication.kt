package com.keen

import com.keen.entity.Product
import com.keen.repository.ProductRepository
import org.springframework.boot.CommandLineRunner
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.context.annotation.Bean
import java.math.BigDecimal

@SpringBootApplication
class KeenPosApplication {
    
    @Bean
    fun init(productRepository: ProductRepository) = CommandLineRunner {
        // Seed initial products
        val products = listOf(
            Product(
                name = "Blaze Blue Dynamic Runner Shoes",
                description = "Premium athletic running shoes with advanced cushioning",
                category = "Shoes",
                price = BigDecimal("1500.00"),
                stockQuantity = 24,
                sizes = mutableListOf("36", "37", "38", "39", "40", "41", "42"),
                imageUrl = "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400"
            ),
            Product(
                name = "Pink Surge High-Performance Trainer",
                description = "High-performance training shoes with excellent grip",
                category = "Shoes",
                price = BigDecimal("2500.00"),
                stockQuantity = 18,
                sizes = mutableListOf("36", "37", "38", "39", "40", "41", "42"),
                imageUrl = "https://images.unsplash.com/photo-1549622260-7cfb35326109?w=400"
            ),
            Product(
                name = "Swift Glow All-Terrain Racing Sneakers",
                description = "All-terrain racing sneakers with superior comfort",
                category = "Shoes",
                price = BigDecimal("4500.00"),
                stockQuantity = 12,
                sizes = mutableListOf("36", "37", "38", "39", "40", "41", "42"),
                imageUrl = "https://images.unsplash.com/photo-1460353581641-37baddab0fa2?w=400"
            ),
            Product(
                name = "Shadow Stride Performance Shoe",
                description = "Professional performance shoe for serious athletes",
                category = "Shoes",
                price = BigDecimal("1350.00"),
                stockQuantity = 30,
                sizes = mutableListOf("36", "37", "38", "39", "40", "41", "42", "43", "44"),
                imageUrl = "https://images.unsplash.com/photo-1552062407-d5d1b56d9358?w=400"
            ),
            Product(
                name = "Lush Stride Comfort Walker Shoes",
                description = "Comfortable everyday walking shoes",
                category = "Shoes",
                price = BigDecimal("1500.00"),
                stockQuantity = 40,
                sizes = mutableListOf("36", "37", "38", "39", "40", "41", "42", "43", "44"),
                imageUrl = "https://images.unsplash.com/photo-1491553895911-0055eca6402d?w=400"
            ),
            Product(
                name = "Midnight Velocity Pro Runner",
                description = "Professional runner shoes for competitive athletes",
                category = "Shoes",
                price = BigDecimal("3500.00"),
                stockQuantity = 15,
                sizes = mutableListOf("37", "38", "39", "40", "41", "42", "43"),
                imageUrl = "https://images.unsplash.com/photo-1556821552-5ff63b1c3da9?w=400"
            ),
            Product(
                name = "Obsidian Dash Ultra Fit",
                description = "Ultra-fit design for maximum performance",
                category = "Shoes",
                price = BigDecimal("2800.00"),
                stockQuantity = 20,
                sizes = mutableListOf("36", "37", "38", "39", "40", "41", "42"),
                imageUrl = "https://images.unsplash.com/photo-1533635239b2-3e69e2c58f19?w=400"
            ),
            Product(
                name = "HP Probook 450 G10",
                description = "Professional laptop with powerful performance",
                category = "Electronics",
                price = BigDecimal("80000.00"),
                stockQuantity = 8,
                sizes = mutableListOf("15.6"),
                imageUrl = "https://images.unsplash.com/photo-1588872657840-218e412ee5ff?w=400"
            ),
            Product(
                name = "Sony WH-1000XM5",
                description = "Premium noise-cancelling headphones",
                category = "Electronics",
                price = BigDecimal("15000.00"),
                stockQuantity = 12,
                sizes = mutableListOf("One Size"),
                imageUrl = "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=400"
            ),
            Product(
                name = "Anker Quick Charger",
                description = "Fast charging cable with durable construction",
                category = "Accessories",
                price = BigDecimal("2500.00"),
                stockQuantity = 50,
                sizes = mutableListOf("1m", "2m", "3m"),
                imageUrl = "https://images.unsplash.com/photo-1591920591022-7099deea9b51?w=400"
            )
        )
        
        productRepository.saveAll(products)
        println("Initialized ${products.size} products")
    }
}

fun main(args: Array<String>) {
    runApplication<KeenPosApplication>(*args)
}

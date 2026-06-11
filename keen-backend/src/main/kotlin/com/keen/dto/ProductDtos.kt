package com.keen.dto

import java.math.BigDecimal

data class ProductResponse(
    val id: Long,
    val name: String,
    val description: String,
    val category: String,
    val brand: String,
    val price: BigDecimal,
    val costPrice: BigDecimal,
    val stockQuantity: Int,
    val sizes: List<String>,
    val colors: List<String>,
    val imageUrl: String,
    val imageUrls: List<String>
)

data class CreateProductRequest(
    val name: String,
    val description: String,
    val category: String,
    val brand: String? = "",
    val price: BigDecimal,
    val costPrice: BigDecimal = BigDecimal.ZERO,
    val stockQuantity: Int,
    val sizes: List<String> = emptyList(),
    val colors: List<String> = emptyList(),
    val imageUrl: String = "",
    val imageUrls: List<String> = emptyList()
)

data class UpdateProductRequest(
    val name: String,
    val description: String,
    val category: String,
    val brand: String? = "",
    val price: BigDecimal,
    val costPrice: BigDecimal = BigDecimal.ZERO,
    val stockQuantity: Int,
    val sizes: List<String> = emptyList(),
    val colors: List<String> = emptyList(),
    val imageUrl: String = "",
    val imageUrls: List<String> = emptyList()
)

data class ProductListResponse(
    val content: List<ProductResponse>,
    val totalElements: Long,
    val totalPages: Int,
    val currentPage: Int
)

data class ProductMetadataResponse(
    val categories: List<String>,
    val brands: List<String>,
    val sizes: List<String>,
    val colors: List<String>
)

data class ProductSalesData(
    val productId: Long,
    val productName: String,
    val quantitySold: Long,
    val totalRevenue: BigDecimal
)

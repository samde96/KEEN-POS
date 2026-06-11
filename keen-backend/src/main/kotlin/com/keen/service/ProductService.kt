package com.keen.service

import com.keen.dto.CreateProductRequest
import com.keen.dto.ProductResponse
import com.keen.dto.ProductListResponse
import com.keen.dto.ProductMetadataResponse
import com.keen.dto.UpdateProductRequest
import com.keen.entity.Product
import com.keen.repository.ProductRepository
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import java.time.LocalDateTime

@Service
class ProductService(
    private val productRepository: ProductRepository
) {
    
    fun getAllProducts(pageable: Pageable): ProductListResponse {
        val page = productRepository.findByIsActive(true, pageable)
        return ProductListResponse(
            content = page.content.map { it.toResponse() },
            totalElements = page.totalElements,
            totalPages = page.totalPages,
            currentPage = page.number
        )
    }
    
    fun getProductsByCategory(category: String, pageable: Pageable): ProductListResponse {
        val page = productRepository.findByCategory(category, pageable)
        return ProductListResponse(
            content = page.content.map { it.toResponse() },
            totalElements = page.totalElements,
            totalPages = page.totalPages,
            currentPage = page.number
        )
    }
    
    fun searchProducts(searchTerm: String, pageable: Pageable): ProductListResponse {
        val page = productRepository.searchProducts(searchTerm, pageable)
        return ProductListResponse(
            content = page.content.map { it.toResponse() },
            totalElements = page.totalElements,
            totalPages = page.totalPages,
            currentPage = page.number
        )
    }
    
    fun getProductById(id: Long): ProductResponse {
        val product = productRepository.findById(id).orElseThrow {
            IllegalArgumentException("Product not found")
        }
        return product.toResponse()
    }

    fun getProductMetadata(): ProductMetadataResponse {
        return ProductMetadataResponse(
            categories = productRepository.findDistinctCategories(),
            brands = productRepository.findDistinctBrands(),
            sizes = productRepository.findDistinctSizes(),
            colors = productRepository.findDistinctColors()
        )
    }
    
    fun createProduct(request: CreateProductRequest): ProductResponse {
        val photoUrls = normalizePhotoUrls(request.imageUrl, request.imageUrls)
        val product = Product(
            name = request.name,
            description = request.description,
            category = request.category,
            brand = request.brand.orEmpty(),
            price = request.price,
            costPrice = request.costPrice,
            stockQuantity = request.stockQuantity,
            sizes = normalizeTags(request.sizes).toMutableList(),
            colors = normalizeTags(request.colors).toMutableList(),
            imageUrl = photoUrls.firstOrNull().orEmpty(),
            imageUrls = photoUrls.toMutableList()
        )
        
        val savedProduct = productRepository.save(product)
        return savedProduct.toResponse()
    }
    
    fun updateProduct(id: Long, request: UpdateProductRequest): ProductResponse {
        val product = productRepository.findById(id).orElseThrow {
            IllegalArgumentException("Product not found")
        }
        
        val photoUrls = normalizePhotoUrls(request.imageUrl, request.imageUrls)
        val updatedProduct = product.copy(
            name = request.name,
            description = request.description,
            category = request.category,
            brand = request.brand.orEmpty(),
            price = request.price,
            costPrice = request.costPrice,
            stockQuantity = request.stockQuantity,
            sizes = normalizeTags(request.sizes).toMutableList(),
            colors = normalizeTags(request.colors).toMutableList(),
            imageUrl = photoUrls.firstOrNull().orEmpty(),
            imageUrls = photoUrls.toMutableList(),
            updatedAt = LocalDateTime.now()
        )
        
        val saved = productRepository.save(updatedProduct)
        return saved.toResponse()
    }
    
    fun deleteProduct(id: Long) {
        productRepository.deleteById(id)
    }
    
    private fun Product.toResponse() = ProductResponse(
        id = this.id,
        name = this.name,
        description = this.description,
        category = this.category,
        brand = this.brand.orEmpty(),
        price = this.price,
        costPrice = this.costPrice,
        stockQuantity = this.stockQuantity,
        sizes = this.sizes,
        colors = this.colors,
        imageUrl = this.imageUrl,
        imageUrls = if (this.imageUrls.isNotEmpty()) this.imageUrls else listOf(this.imageUrl).filter { it.isNotBlank() }
    )

    private fun normalizeTags(values: List<String>): List<String> {
        return values
            .map { it.trim() }
            .filter { it.isNotEmpty() }
            .distinctBy { it.lowercase() }
    }

    private fun normalizePhotoUrls(primaryImageUrl: String, imageUrls: List<String>): List<String> {
        return (listOf(primaryImageUrl) + imageUrls)
            .map { it.trim() }
            .filter { it.isNotEmpty() }
            .distinct()
    }
}

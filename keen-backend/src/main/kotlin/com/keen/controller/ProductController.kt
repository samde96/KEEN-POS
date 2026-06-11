package com.keen.controller

import com.keen.dto.CreateProductRequest
import com.keen.dto.ProductResponse
import com.keen.dto.ProductListResponse
import com.keen.dto.ProductMetadataResponse
import com.keen.dto.UpdateProductRequest
import com.keen.service.ProductService
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Pageable
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.DeleteMapping
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.PutMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/products")
class ProductController(
    private val productService: ProductService
) {
    
    @GetMapping
    fun getAllProducts(
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "10") size: Int
    ): ResponseEntity<ProductListResponse> {
        val pageable: Pageable = PageRequest.of(page, size)
        return ResponseEntity.ok(productService.getAllProducts(pageable))
    }
    
    @GetMapping("/search")
    fun searchProducts(
        @RequestParam searchTerm: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "10") size: Int
    ): ResponseEntity<ProductListResponse> {
        val pageable: Pageable = PageRequest.of(page, size)
        return ResponseEntity.ok(productService.searchProducts(searchTerm, pageable))
    }
    
    @GetMapping("/category/{category}")
    fun getProductsByCategory(
        @PathVariable category: String,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "10") size: Int
    ): ResponseEntity<ProductListResponse> {
        val pageable: Pageable = PageRequest.of(page, size)
        return ResponseEntity.ok(productService.getProductsByCategory(category, pageable))
    }

    @GetMapping("/metadata")
    fun getProductMetadata(): ResponseEntity<ProductMetadataResponse> {
        return ResponseEntity.ok(productService.getProductMetadata())
    }
    
    @GetMapping("/{id}")
    fun getProductById(@PathVariable id: Long): ResponseEntity<ProductResponse> {
        return try {
            val product = productService.getProductById(id)
            ResponseEntity.ok(product)
        } catch (ex: Exception) {
            ResponseEntity.notFound().build()
        }
    }
    
    @PostMapping
    fun createProduct(@RequestBody request: CreateProductRequest): ResponseEntity<ProductResponse> {
        return try {
            val product = productService.createProduct(request)
            ResponseEntity.ok(product)
        } catch (ex: Exception) {
            ResponseEntity.badRequest().build()
        }
    }
    
    @PutMapping("/{id}")
    fun updateProduct(
        @PathVariable id: Long,
        @RequestBody request: UpdateProductRequest
    ): ResponseEntity<ProductResponse> {
        return try {
            val product = productService.updateProduct(id, request)
            ResponseEntity.ok(product)
        } catch (ex: Exception) {
            ResponseEntity.badRequest().build()
        }
    }
    
    @DeleteMapping("/{id}")
    fun deleteProduct(@PathVariable id: Long): ResponseEntity<Void> {
        return try {
            productService.deleteProduct(id)
            ResponseEntity.ok().build()
        } catch (ex: Exception) {
            ResponseEntity.badRequest().build()
        }
    }
}

package com.keen.controller

import com.keen.dto.CreateOrderRequest
import com.keen.dto.OrderResponse
import com.keen.dto.OrderListResponse
import com.keen.dto.DashboardMetrics
import com.keen.dto.SalesReportResponse
import com.keen.service.OrderService
import com.keen.security.CustomUserDetails
import org.springframework.data.domain.PageRequest
import org.springframework.data.domain.Pageable
import org.springframework.http.ResponseEntity
import org.springframework.security.core.annotation.AuthenticationPrincipal
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PathVariable
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/orders")
class OrderController(
    private val orderService: OrderService
) {
    
    @GetMapping
    fun getUserOrders(
        @AuthenticationPrincipal userDetails: CustomUserDetails,
        @RequestParam(defaultValue = "0") page: Int,
        @RequestParam(defaultValue = "10") size: Int
    ): ResponseEntity<OrderListResponse> {
        val pageable: Pageable = PageRequest.of(page, size)
        return ResponseEntity.ok(orderService.getUserOrders(userDetails.getId(), pageable))
    }
    
    @GetMapping("/{id}")
    fun getOrderById(@PathVariable id: Long): ResponseEntity<OrderResponse> {
        return try {
            val order = orderService.getOrderById(id)
            ResponseEntity.ok(order)
        } catch (ex: Exception) {
            ResponseEntity.notFound().build()
        }
    }
    
    @PostMapping
    fun createOrder(
        @AuthenticationPrincipal userDetails: CustomUserDetails,
        @RequestBody request: CreateOrderRequest
    ): ResponseEntity<OrderResponse> {
        return try {
            val order = orderService.createOrder(userDetails.getId(), request)
            ResponseEntity.ok(order)
        } catch (ex: Exception) {
            ResponseEntity.badRequest().build()
        }
    }
    
    @GetMapping("/dashboard/metrics")
    fun getDashboardMetrics(): ResponseEntity<DashboardMetrics> {
        return ResponseEntity.ok(orderService.getDashboardMetrics())
    }

    @GetMapping("/reports")
    fun getSalesReport(
        @RequestParam(defaultValue = "weekly") period: String
    ): ResponseEntity<SalesReportResponse> {
        return ResponseEntity.ok(orderService.getSalesReport(period))
    }
}

package com.keen.dto

import java.math.BigDecimal

data class OrderItemRequest(
    val productId: Long,
    val quantity: Int,
    val size: String
)

data class CreateOrderRequest(
    val items: List<OrderItemRequest>,
    val subtotal: BigDecimal,
    val taxAmount: BigDecimal,
    val discountAmount: BigDecimal,
    val totalAmount: BigDecimal,
    val paymentMethod: String
)

data class OrderItemResponse(
    val id: Long,
    val productId: Long,
    val productName: String,
    val quantity: Int,
    val size: String,
    val priceAtPurchase: BigDecimal,
    val costAtPurchase: BigDecimal,
    val profitAmount: BigDecimal,
    val subtotal: BigDecimal
)

data class OrderResponse(
    val id: Long,
    val orderNumber: String,
    val items: List<OrderItemResponse>,
    val subtotal: BigDecimal,
    val taxAmount: BigDecimal,
    val discountAmount: BigDecimal,
    val totalAmount: BigDecimal,
    val paymentMethod: String,
    val status: String,
    val createdAt: String
)

data class OrderListResponse(
    val content: List<OrderResponse>,
    val totalElements: Long,
    val totalPages: Int,
    val currentPage: Int
)

data class DashboardMetrics(
    val totalSales: BigDecimal,
    val totalOrders: Long,
    val totalProducts: Long,
    val productsIn: Long,
    val productsOut: Long,
    val revenueData: List<RevenueDayData>
)

data class RevenueDayData(
    val day: String,
    val revenue: BigDecimal
)

data class SalesReportResponse(
    val period: String,
    val totalSales: BigDecimal,
    val grossProfit: BigDecimal,
    val totalLoss: BigDecimal,
    val costOfGoods: BigDecimal,
    val totalDiscounts: BigDecimal,
    val totalTax: BigDecimal,
    val totalOrders: Long,
    val itemsSold: Long,
    val averageOrderValue: BigDecimal,
    val data: List<SalesReportPoint>
)

data class SalesReportPoint(
    val label: String,
    val sales: BigDecimal,
    val profit: BigDecimal,
    val loss: BigDecimal,
    val orders: Long
)

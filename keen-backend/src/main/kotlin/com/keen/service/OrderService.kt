package com.keen.service

import com.keen.dto.CreateOrderRequest
import com.keen.dto.OrderResponse
import com.keen.dto.OrderListResponse
import com.keen.dto.DashboardMetrics
import com.keen.dto.RevenueDayData
import com.keen.dto.SalesReportPoint
import com.keen.dto.SalesReportResponse
import com.keen.dto.ProductSalesData
import com.keen.dto.ProductResponse
import com.keen.entity.Order
import com.keen.entity.OrderItem
import com.keen.entity.PaymentMethod
import com.keen.entity.OrderStatus
import com.keen.repository.OrderRepository
import com.keen.repository.ProductRepository
import com.keen.repository.UserRepository
import org.springframework.data.domain.Pageable
import org.springframework.stereotype.Service
import java.math.BigDecimal
import java.math.RoundingMode
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.YearMonth
import java.time.format.DateTimeFormatter
import java.util.UUID

@Service
class OrderService(
    private val orderRepository: OrderRepository,
    private val productRepository: ProductRepository,
    private val userRepository: UserRepository
) {
    
    fun getUserOrders(userId: Long, pageable: Pageable): OrderListResponse {
        val page = orderRepository.findByUserId(userId, pageable)
        return OrderListResponse(
            content = page.content.map { it.toResponse() },
            totalElements = page.totalElements,
            totalPages = page.totalPages,
            currentPage = page.number
        )
    }
    
    fun getOrderById(id: Long): OrderResponse {
        val order = orderRepository.findById(id).orElseThrow {
            IllegalArgumentException("Order not found")
        }
        return order.toResponse()
    }
    
    fun createOrder(userId: Long, request: CreateOrderRequest): OrderResponse {
        val user = userRepository.findById(userId).orElseThrow {
            IllegalArgumentException("User not found")
        }
        
        val orderNumber = "ORD-${System.currentTimeMillis()}-${UUID.randomUUID().toString().take(4)}"
        
        val orderItems = mutableListOf<OrderItem>()
        request.items.forEach { item ->
            val product = productRepository.findById(item.productId).orElseThrow {
                IllegalArgumentException("Product not found: ${item.productId}")
            }
            
            if (product.stockQuantity < item.quantity) {
                throw IllegalArgumentException("Insufficient stock for product: ${product.name}")
            }
            
            // Update stock
            val updatedProduct = product.copy(
                stockQuantity = product.stockQuantity - item.quantity
            )
            productRepository.save(updatedProduct)

            val subtotal = product.price.multiply(BigDecimal(item.quantity))
            val costSubtotal = product.costPrice.multiply(BigDecimal(item.quantity))
            val profitAmount = subtotal.subtract(costSubtotal)
            orderItems.add(
                OrderItem(
                    product = updatedProduct,
                    quantity = item.quantity,
                    size = item.size,
                    priceAtPurchase = product.price,
                    costAtPurchase = product.costPrice,
                    profitAmount = profitAmount,
                    subtotal = subtotal
                )
            )
        }
        
        val paymentMethod = PaymentMethod.valueOf(request.paymentMethod.uppercase())
        
        val savedOrder = orderRepository.save(
            Order(
                orderNumber = orderNumber,
                user = user,
                subtotal = request.subtotal,
                taxAmount = request.taxAmount,
                discountAmount = request.discountAmount,
                totalAmount = request.totalAmount,
                paymentMethod = paymentMethod,
                status = OrderStatus.COMPLETED
            )
        )

        val order = savedOrder.copy(
            orderNumber = orderNumber,
            user = user,
            items = orderItems.map { item -> item.copy(order = savedOrder) }.toMutableList(),
            subtotal = request.subtotal,
            taxAmount = request.taxAmount,
            discountAmount = request.discountAmount,
            totalAmount = request.totalAmount,
            paymentMethod = paymentMethod,
            status = OrderStatus.COMPLETED
        )
        
        return orderRepository.save(order).toResponse()
    }
    
    fun getDashboardMetrics(): DashboardMetrics {
        val weeklyReport = getSalesReport("weekly")
        val totalProducts = productRepository.count()
        val productsIn = productRepository.findAll().sumOf { it.stockQuantity.toLong() }
        val productsOut = weeklyReport.itemsSold
        
        val revenueData = weeklyReport.data.map { point ->
            RevenueDayData(point.label.uppercase(), point.sales)
        }
        
        return DashboardMetrics(
            totalSales = weeklyReport.totalSales,
            totalOrders = weeklyReport.totalOrders,
            totalProducts = totalProducts,
            productsIn = productsIn,
            productsOut = productsOut,
            revenueData = revenueData
        )
    }

    fun getSalesReport(period: String): SalesReportResponse {
        val normalizedPeriod = period.lowercase()
        val buckets: List<ReportBucket> = buildReportBuckets(normalizedPeriod) // Explicit type for buckets
        val firstBucket: ReportBucket = buckets.first() // Explicit type for firstBucket
        val lastBucket: ReportBucket = buckets.last()   // Explicit type for lastBucket
        val reportStart = firstBucket.start
        val reportEnd = lastBucket.end.minusNanos(1)
        val orders = orderRepository.findByStatusAndCreatedAtBetween(
            OrderStatus.COMPLETED,
            reportStart,
            reportEnd
        )

        val points = buckets.map { bucket ->
            val bucketOrders = orders.filter { order ->
                !order.createdAt.isBefore(bucket.start) && order.createdAt.isBefore(bucket.end)
            }
            bucket.toPoint(bucketOrders)
        }

        val totalSales = orders.sumOfMoney { it.totalAmount }
        val costOfGoods = orders.sumOfMoney { it.costOfGoods() }
        val totalDiscounts = orders.sumOfMoney { it.discountAmount }
        val totalTax = orders.sumOfMoney { it.taxAmount }
        val netRevenue = orders.sumOfMoney { it.subtotal.subtract(it.discountAmount) }
        val netProfit = netRevenue.subtract(costOfGoods)
        val grossProfit = netProfit.positiveOnly()
        val totalLoss = netProfit.negativeAsPositive()
        val itemsSold = orders.sumOf { order -> order.items.sumOf { it.quantity.toLong() } }
        val averageOrderValue = if (orders.isEmpty()) {
            BigDecimal.ZERO
        } else {
            totalSales.divide(BigDecimal(orders.size), 2, RoundingMode.HALF_UP)
        }

        // Calculate best-selling and least-selling products
        val productSalesMap = orders
            .flatMap { it.items }
            .groupBy { it.product.id }
            .map { (productId, items) ->
                val product = items.first().product // Get product details from the first item
                ProductSalesData(
                    productId = productId,
                    productName = product.name ?: "Unknown Product",
                    quantitySold = items.sumOf { it.quantity.toLong() },
                    totalRevenue = items.sumOfMoney { it.subtotal }
                )
            }

        val bestSellingProducts = productSalesMap
            .sortedByDescending { it.quantitySold }
            .take(5)

        val leastSellingProducts = productSalesMap
            .sortedBy { it.quantitySold }
            .take(5)

        // Calculate low stock items
        val lowStockThreshold = 10 // Define your low stock threshold
        val lowStockItems = productRepository.findAll()
            .filter { it.stockQuantity <= lowStockThreshold }
            .map { it.toResponse() }

        return SalesReportResponse(
            period = normalizedPeriod,
            totalSales = totalSales,
            grossProfit = grossProfit,
            totalLoss = totalLoss,
            costOfGoods = costOfGoods,
            totalDiscounts = totalDiscounts,
            totalTax = totalTax,
            totalOrders = orders.size.toLong(),
            itemsSold = itemsSold,
            averageOrderValue = averageOrderValue,
            data = points,
            bestSellingProducts = bestSellingProducts,
            leastSellingProducts = leastSellingProducts,
            lowStockItems = lowStockItems
        )
    }
    
    private fun Order.toResponse() = OrderResponse(
        id = this.id,
        orderNumber = this.orderNumber,
        items = this.items.map { item ->
            com.keen.dto.OrderItemResponse(
                id = item.id,
                productId = item.product.id,
                productName = item.product.name,
                quantity = item.quantity,
                size = item.size,
                priceAtPurchase = item.priceAtPurchase,
                costAtPurchase = item.costAtPurchase,
                profitAmount = item.profitAmount,
                subtotal = item.subtotal
            )
        },
        subtotal = this.subtotal,
        taxAmount = this.taxAmount,
        discountAmount = this.discountAmount,
        totalAmount = this.totalAmount,
        paymentMethod = this.paymentMethod.name,
        status = this.status.name,
        createdAt = this.createdAt.format(DateTimeFormatter.ISO_DATE_TIME)
    )

    private fun com.keen.entity.Product.toResponse() = ProductResponse(
        id = this.id,
        name = this.name,
        description = this.description,
        category = this.category,
        brand = this.brand ?: "",
        price = this.price,
        costPrice = this.costPrice,
        stockQuantity = this.stockQuantity,
        sizes = this.sizes,
        colors = this.colors,
        imageUrl = this.imageUrl ?: "",
        imageUrls = this.imageUrls
    )

    private fun buildReportBuckets(period: String): List<ReportBucket> {
        val today = LocalDate.now()
        return when (period) {
            "daily" -> {
                val start = today.atStartOfDay()
                (0 until 24).map { hour ->
                    ReportBucket(
                        label = start.plusHours(hour.toLong()).format(DateTimeFormatter.ofPattern("HH:mm")),
                        start = start.plusHours(hour.toLong()),
                        end = start.plusHours(hour.toLong() + 1)
                    )
                }
            }
            "monthly" -> {
                val month = YearMonth.from(today)
                (1..month.lengthOfMonth()).map { day ->
                    val start = month.atDay(day).atStartOfDay()
                    ReportBucket(
                        label = day.toString(),
                        start = start,
                        end = start.plusDays(1)
                    )
                }
            }
            "yearly" -> {
                (1..12).map { month ->
                    val start = LocalDate.of(today.year, month, 1).atStartOfDay()
                    ReportBucket(
                        label = start.format(DateTimeFormatter.ofPattern("MMM")),
                        start = start,
                        end = start.plusMonths(1)
                    )
                }
            }
            else -> {
                val startDate = today.with(DayOfWeek.MONDAY)
                (0 until 7).map { dayOffset ->
                    val start = startDate.plusDays(dayOffset.toLong()).atStartOfDay()
                    ReportBucket(
                        label = start.dayOfWeek.name.take(3),
                        start = start,
                        end = start.plusDays(1)
                    )
                }
            }
        }
    }

    private fun ReportBucket.toPoint(orders: List<Order>): SalesReportPoint {
        val sales = orders.sumOfMoney { it.totalAmount }
        val costOfGoods = orders.sumOfMoney { it.costOfGoods() }
        val netRevenue = orders.sumOfMoney { it.subtotal.subtract(it.discountAmount) }
        val netProfit = netRevenue.subtract(costOfGoods)

        return SalesReportPoint(
            label = label,
            sales = sales,
            profit = netProfit.positiveOnly(),
            loss = netProfit.negativeAsPositive(),
            orders = orders.size.toLong()
        )
    }

    private fun Order.costOfGoods(): BigDecimal {
        return items.sumOfMoney { item ->
            item.costAtPurchase.multiply(BigDecimal(item.quantity))
        }
    }

    private fun <T> Iterable<T>.sumOfMoney(selector: (T) -> BigDecimal): BigDecimal {
        return fold(BigDecimal.ZERO) { total, item -> total.add(selector(item)) }
    }

    private fun BigDecimal.positiveOnly(): BigDecimal {
        return if (this > BigDecimal.ZERO) this else BigDecimal.ZERO
    }

    private fun BigDecimal.negativeAsPositive(): BigDecimal {
        return if (this < BigDecimal.ZERO) this.abs() else BigDecimal.ZERO
    }

    private data class ReportBucket(
        val label: String,
        val start: LocalDateTime,
        val end: LocalDateTime
    )
}

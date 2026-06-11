package com.keen.repository

import com.keen.entity.Order
import com.keen.entity.OrderStatus
import org.springframework.data.domain.Page
import org.springframework.data.domain.Pageable
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.data.jpa.repository.Query
import org.springframework.stereotype.Repository
import java.math.BigDecimal
import java.time.LocalDateTime

@Repository
interface OrderRepository : JpaRepository<Order, Long> {
    fun findByUserId(userId: Long, pageable: Pageable): Page<Order>
    
    fun findByOrderNumber(orderNumber: String): Order?

    fun findByStatusAndCreatedAtBetween(
        status: OrderStatus,
        startDate: LocalDateTime,
        endDate: LocalDateTime
    ): List<Order>
    
    @Query("SELECT SUM(o.totalAmount) FROM Order o WHERE o.createdAt >= :startDate AND o.createdAt <= :endDate")
    fun getTotalSalesBetweenDates(startDate: LocalDateTime, endDate: LocalDateTime): BigDecimal?
    
    @Query("SELECT COUNT(o) FROM Order o WHERE o.createdAt >= :startDate AND o.createdAt <= :endDate")
    fun getOrderCountBetweenDates(startDate: LocalDateTime, endDate: LocalDateTime): Long
}

package com.keen.entity

import jakarta.persistence.*
import java.math.BigDecimal
import java.time.LocalDateTime

@Entity
@Table(name = "orders")
data class Order(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @Column(name = "order_number", nullable = false, unique = true)
    val orderNumber: String = "",

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    val user: User = User(),

    @OneToMany(mappedBy = "order", cascade = [CascadeType.ALL], orphanRemoval = true, fetch = FetchType.EAGER)
    val items: MutableList<OrderItem> = mutableListOf(),

    @Column(name = "subtotal", nullable = false, precision = 19, scale = 2)
    val subtotal: BigDecimal = BigDecimal.ZERO,

    @Column(name = "tax_amount", nullable = false, precision = 19, scale = 2)
    val taxAmount: BigDecimal = BigDecimal.ZERO,

    @Column(name = "discount_amount", nullable = false, precision = 19, scale = 2)
    val discountAmount: BigDecimal = BigDecimal.ZERO,

    @Column(name = "total_amount", nullable = false, precision = 19, scale = 2)
    val totalAmount: BigDecimal = BigDecimal.ZERO,

    @Column(name = "payment_method", nullable = false)
    @Enumerated(EnumType.STRING)
    val paymentMethod: PaymentMethod = PaymentMethod.CASH,

    @Column(name = "status", nullable = false)
    @Enumerated(EnumType.STRING)
    val status: OrderStatus = OrderStatus.PENDING,

    @Column(name = "created_at", nullable = false, updatable = false)
    val createdAt: LocalDateTime = LocalDateTime.now(),

    @Column(name = "updated_at", nullable = false)
    val updatedAt: LocalDateTime = LocalDateTime.now()
)

@Entity
@Table(name = "order_items")
data class OrderItem(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0,

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "order_id", nullable = false)
    val order: Order = Order(),

    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "product_id", nullable = false)
    val product: Product = Product(),

    @Column(name = "quantity", nullable = false)
    val quantity: Int = 1,

    @Column(name = "size", nullable = false)
    val size: String = "",

    @Column(name = "price_at_purchase", nullable = false, precision = 19, scale = 2)
    val priceAtPurchase: BigDecimal = BigDecimal.ZERO,

    @Column(name = "cost_at_purchase", nullable = false, precision = 19, scale = 2)
    val costAtPurchase: BigDecimal = BigDecimal.ZERO,

    @Column(name = "profit_amount", nullable = false, precision = 19, scale = 2)
    val profitAmount: BigDecimal = BigDecimal.ZERO,

    @Column(name = "subtotal", nullable = false, precision = 19, scale = 2)
    val subtotal: BigDecimal = BigDecimal.ZERO
)

enum class PaymentMethod {
    CASH, MPESA, CARD, DEBIT, E_WALLET, TRANSFER, SCAN
}

enum class OrderStatus {
    PENDING, COMPLETED, CANCELLED, REFUNDED
}
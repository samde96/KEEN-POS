// User & Auth Models
class User {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String? profilePhotoUrl;

  User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    this.profilePhotoUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      role: json['role'] as String,
      profilePhotoUrl: json['profilePhotoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  User copyWith({
    int? id,
    String? email,
    String? firstName,
    String? lastName,
    String? role,
    String? profilePhotoUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role ?? this.role,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
    );
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

// Settings Models
class MpesaSettings {
  final String consumerKey;
  final String consumerSecret;
  final String passKey;
  final String shortCode;
  final String initiatorName;
  final String securityCredential;

  MpesaSettings({
    required this.consumerKey,
    required this.consumerSecret,
    required this.passKey,
    required this.shortCode,
    required this.initiatorName,
    required this.securityCredential,
  });

  factory MpesaSettings.empty() {
    return MpesaSettings(
      consumerKey: '',
      consumerSecret: '',
      passKey: '',
      shortCode: '',
      initiatorName: '',
      securityCredential: '',
    );
  }

  factory MpesaSettings.fromJson(Map<String, dynamic> json) {
    return MpesaSettings(
      consumerKey: json['consumerKey'] as String? ?? '',
      consumerSecret: json['consumerSecret'] as String? ?? '',
      passKey: json['passKey'] as String? ?? '',
      shortCode: json['shortCode'] as String? ?? '',
      initiatorName: json['initiatorName'] as String? ?? '',
      securityCredential: json['securityCredential'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'consumerKey': consumerKey,
      'consumerSecret': consumerSecret,
      'passKey': passKey,
      'shortCode': shortCode,
      'initiatorName': initiatorName,
      'securityCredential': securityCredential,
    };
  }
}

// Product Models
class Product {
  final int id;
  final String name;
  final String description;
  final String category;
  final String brand;
  final double price;
  final double costPrice;
  final int stockQuantity;
  final List<String> sizes;
  final List<String> colors;
  final String imageUrl;
  final List<String> imageUrls;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.brand,
    required this.price,
    required this.costPrice,
    required this.stockQuantity,
    required this.sizes,
    required this.colors,
    required this.imageUrl,
    required this.imageUrls,
  });

  double get grossProfit => price - costPrice;
  double get marginPercentage => price > 0 ? (grossProfit / price) * 100 : 0;

  factory Product.fromJson(Map<String, dynamic> json) {
    final primaryImageUrl = json['imageUrl'] as String? ?? '';
    final imageUrls = List<String>.from((json['imageUrls'] as List?) ?? const []);

    return Product(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      brand: json['brand'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      costPrice: (json['costPrice'] as num?)?.toDouble() ?? 0,
      stockQuantity: json['stockQuantity'] as int,
      sizes: List<String>.from((json['sizes'] as List?) ?? const []),
      colors: List<String>.from((json['colors'] as List?) ?? const []),
      imageUrl: primaryImageUrl,
      imageUrls: imageUrls.isNotEmpty
          ? imageUrls
          : primaryImageUrl.isNotEmpty
              ? [primaryImageUrl]
              : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'brand': brand,
      'price': price,
      'costPrice': costPrice,
      'stockQuantity': stockQuantity,
      'sizes': sizes,
      'colors': colors,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
    };
  }
}

class ProductMetadata {
  final List<String> categories;
  final List<String> brands;
  final List<String> sizes;
  final List<String> colors;

  ProductMetadata({
    required this.categories,
    required this.brands,
    required this.sizes,
    required this.colors,
  });

  factory ProductMetadata.empty() {
    return ProductMetadata(
      categories: const [],
      brands: const [],
      sizes: const [],
      colors: const [],
    );
  }

  factory ProductMetadata.fromJson(Map<String, dynamic> json) {
    return ProductMetadata(
      categories: List<String>.from((json['categories'] as List?) ?? const []),
      brands: List<String>.from((json['brands'] as List?) ?? const []),
      sizes: List<String>.from((json['sizes'] as List?) ?? const []),
      colors: List<String>.from((json['colors'] as List?) ?? const []),
    );
  }
}

class ProductList {
  final List<Product> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  ProductList({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory ProductList.fromJson(Map<String, dynamic> json) {
    return ProductList(
      content: (json['content'] as List)
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
    );
  }
}

// Cart Models
class CartItem {
  final Product product;
  int quantity;
  final String size;

  CartItem({
    required this.product,
    required this.quantity,
    required this.size,
  });

  double get subtotal => product.price * quantity;
}

class Cart {
  List<CartItem> items = [];
  double taxRate = 0.10;
  double discount = 0.0;

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);
  double get tax => subtotal * taxRate;
  double get total => subtotal + tax - discount;

  void addItem(Product product, int quantity, String size) {
    final existingItem = items.firstWhere(
      (item) => item.product.id == product.id && item.size == size,
      orElse: () => CartItem(product: product, quantity: 0, size: size),
    );

    if (existingItem.quantity == 0) {
      items.add(CartItem(product: product, quantity: quantity, size: size));
    } else {
      existingItem.quantity += quantity;
    }
  }

  void removeItem(int productId, String size) {
    items.removeWhere((item) => item.product.id == productId && item.size == size);
  }

  void updateQuantity(int productId, String size, int quantity) {
    final item = items.firstWhere(
      (item) => item.product.id == productId && item.size == size,
      orElse: () => CartItem(product: Product.fromJson({}), quantity: 0, size: size),
    );
    if (item.quantity > 0) {
      item.quantity = quantity;
    }
  }

  void clear() {
    items.clear();
  }
}

// Order Models
class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final int quantity;
  final String size;
  final double priceAtPurchase;
  final double costAtPurchase;
  final double profitAmount;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.size,
    required this.priceAtPurchase,
    required this.costAtPurchase,
    required this.profitAmount,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] as int,
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      quantity: json['quantity'] as int,
      size: json['size'] as String,
      priceAtPurchase: (json['priceAtPurchase'] as num).toDouble(),
      costAtPurchase: (json['costAtPurchase'] as num?)?.toDouble() ?? 0,
      profitAmount: (json['profitAmount'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

class Order {
  final int id;
  final String orderNumber;
  final List<OrderItem> items;
  final double subtotal;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String paymentMethod;
  final String status;
  final String createdAt;
  final String? customerName;

  Order({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.subtotal,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.customerName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderNumber: json['orderNumber'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentMethod: json['paymentMethod'] as String,
      status: json['status'] as String,
      createdAt: json['createdAt'] as String,
      customerName: json['customerName'] as String?,
    );
  }
}

class OrderList {
  final List<Order> content;
  final int totalElements;
  final int totalPages;
  final int currentPage;

  OrderList({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.currentPage,
  });

  factory OrderList.fromJson(Map<String, dynamic> json) {
    return OrderList(
      content: (json['content'] as List)
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
    );
  }
}

// Dashboard Models
class RevenueDayData {
  final String day;
  final double revenue;

  RevenueDayData({
    required this.day,
    required this.revenue,
  });

  factory RevenueDayData.fromJson(Map<String, dynamic> json) {
    return RevenueDayData(
      day: json['day'] as String,
      revenue: (json['revenue'] as num).toDouble(),
    );
  }
}

class DashboardMetrics {
  final double totalSales;
  final int totalOrders;
  final int totalProducts;
  final int productsIn;
  final int productsOut;
  final List<RevenueDayData> revenueData;

  DashboardMetrics({
    required this.totalSales,
    required this.totalOrders,
    required this.totalProducts,
    required this.productsIn,
    required this.productsOut,
    required this.revenueData,
  });

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      totalSales: (json['totalSales'] as num).toDouble(),
      totalOrders: json['totalOrders'] as int,
      totalProducts: json['totalProducts'] as int,
      productsIn: json['productsIn'] as int,
      productsOut: json['productsOut'] as int,
      revenueData: (json['revenueData'] as List)
          .map((item) => RevenueDayData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SalesReportPoint {
  final String label;
  final double sales;
  final double profit;
  final double loss;
  final int orders;

  SalesReportPoint({
    required this.label,
    required this.sales,
    required this.profit,
    required this.loss,
    required this.orders,
  });

  factory SalesReportPoint.fromJson(Map<String, dynamic> json) {
    return SalesReportPoint(
      label: json['label'] as String,
      sales: (json['sales'] as num).toDouble(),
      profit: (json['profit'] as num).toDouble(),
      loss: (json['loss'] as num).toDouble(),
      orders: json['orders'] as int,
    );
  }
}

class ProductSalesData {
  final int productId;
  final String productName;
  final int quantitySold;
  final double totalRevenue;

  ProductSalesData({
    required this.productId,
    required this.productName,
    required this.quantitySold,
    required this.totalRevenue,
  });

  factory ProductSalesData.fromJson(Map<String, dynamic> json) {
    return ProductSalesData(
      productId: json['productId'] as int,
      productName: json['productName'] as String,
      quantitySold: json['quantitySold'] as int,
      totalRevenue: (json['totalRevenue'] as num).toDouble(),
    );
  }
}

class SalesReport {
  final String period;
  final double totalSales;
  final double grossProfit;
  final double totalLoss;
  final double costOfGoods;
  final double totalDiscounts;
  final double totalTax;
  final int totalOrders;
  final int itemsSold;
  final double averageOrderValue;
  final List<SalesReportPoint> data;
  final List<ProductSalesData> bestSellingProducts;
  final List<ProductSalesData> leastSellingProducts;
  final List<Product> lowStockItems;

  SalesReport({
    required this.period,
    required this.totalSales,
    required this.grossProfit,
    required this.totalLoss,
    required this.costOfGoods,
    required this.totalDiscounts,
    required this.totalTax,
    required this.totalOrders,
    required this.itemsSold,
    required this.averageOrderValue,
    required this.data,
    required this.bestSellingProducts,
    required this.leastSellingProducts,
    required this.lowStockItems,
  });

  factory SalesReport.fromJson(Map<String, dynamic> json) {
    return SalesReport(
      period: json['period'] as String,
      totalSales: (json['totalSales'] as num).toDouble(),
      grossProfit: (json['grossProfit'] as num).toDouble(),
      totalLoss: (json['totalLoss'] as num).toDouble(),
      costOfGoods: (json['costOfGoods'] as num).toDouble(),
      totalDiscounts: (json['totalDiscounts'] as num).toDouble(),
      totalTax: (json['totalTax'] as num).toDouble(),
      totalOrders: json['totalOrders'] as int,
      itemsSold: json['itemsSold'] as int,
      averageOrderValue: (json['averageOrderValue'] as num).toDouble(),
      data: (json['data'] as List)
          .map((item) => SalesReportPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
      bestSellingProducts: (json['bestSellingProducts'] as List? ?? [])
          .map((item) => ProductSalesData.fromJson(item as Map<String, dynamic>))
          .toList(),
      leastSellingProducts: (json['leastSellingProducts'] as List? ?? [])
          .map((item) => ProductSalesData.fromJson(item as Map<String, dynamic>))
          .toList(),
      lowStockItems: (json['lowStockItems'] as List? ?? [])
          .map((item) => Product.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
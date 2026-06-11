import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:keen_pos/models/models.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'keen_pos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Products Table
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY,
        name TEXT,
        description TEXT,
        category TEXT,
        brand TEXT,
        price REAL,
        costPrice REAL,
        stockQuantity INTEGER,
        imageUrl TEXT,
        imageUrls TEXT,
        sizes TEXT,
        colors TEXT
      )
    ''');

    // Orders Table
    await db.execute('''
      CREATE TABLE orders(
        id INTEGER PRIMARY KEY,
        orderNumber TEXT,
        subtotal REAL,
        taxAmount REAL,
        discountAmount REAL,
        totalAmount REAL,
        paymentMethod TEXT,
        status TEXT,
        createdAt TEXT,
        customerName TEXT
      )
    ''');

    // Order Items Table
    await db.execute('''
      CREATE TABLE order_items(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER,
        productId INTEGER,
        productName TEXT,
        quantity INTEGER,
        size TEXT,
        priceAtPurchase REAL,
        costAtPurchase REAL,
        profitAmount REAL,
        subtotal REAL,
        FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');
  }

  // Product Operations
  Future<void> saveProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch();
    
    for (var product in products) {
      batch.insert(
        'products',
        {
          'id': product.id,
          'name': product.name,
          'description': product.description,
          'category': product.category,
          'brand': product.brand,
          'price': product.price,
          'costPrice': product.costPrice,
          'stockQuantity': product.stockQuantity,
          'imageUrl': product.imageUrl,
          'imageUrls': product.imageUrls.join(','),
          'sizes': product.sizes.join(','),
          'colors': product.colors.join(','),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'],
        name: maps[i]['name'],
        description: maps[i]['description'],
        category: maps[i]['category'],
        brand: maps[i]['brand'],
        price: maps[i]['price'],
        costPrice: maps[i]['costPrice'],
        stockQuantity: maps[i]['stockQuantity'],
        imageUrl: maps[i]['imageUrl'],
        imageUrls: (maps[i]['imageUrls'] as String).split(','),
        sizes: (maps[i]['sizes'] as String).split(','),
        colors: (maps[i]['colors'] as String).split(','),
      );
    });
  }

  // Order Operations
  Future<void> saveOrder(Order order) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert(
        'orders',
        {
          'id': order.id,
          'orderNumber': order.orderNumber,
          'subtotal': order.subtotal,
          'taxAmount': order.taxAmount,
          'discountAmount': order.discountAmount,
          'totalAmount': order.totalAmount,
          'paymentMethod': order.paymentMethod,
          'status': order.status,
          'createdAt': order.createdAt,
          'customerName': order.customerName,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      for (var item in order.items) {
        await txn.insert('order_items', {
          'orderId': order.id,
          'productId': item.productId,
          'productName': item.productName,
          'quantity': item.quantity,
          'size': item.size,
          'priceAtPurchase': item.priceAtPurchase,
          'costAtPurchase': item.costAtPurchase,
          'profitAmount': item.profitAmount,
          'subtotal': item.subtotal,
        });
      }
    });
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> orderMaps = await db.query('orders', orderBy: 'createdAt DESC');

    List<Order> orders = [];
    for (var map in orderMaps) {
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [map['id']],
      );

      List<OrderItem> items = itemMaps.map((itemMap) {
        return OrderItem(
          id: itemMap['id'],
          productId: itemMap['productId'],
          productName: itemMap['productName'],
          quantity: itemMap['quantity'],
          size: itemMap['size'],
          priceAtPurchase: itemMap['priceAtPurchase'],
          costAtPurchase: itemMap['costAtPurchase'],
          profitAmount: itemMap['profitAmount'],
          subtotal: itemMap['subtotal'],
        );
      }).toList();

      orders.add(Order(
        id: map['id'],
        orderNumber: map['orderNumber'],
        subtotal: map['subtotal'],
        taxAmount: map['taxAmount'],
        discountAmount: map['discountAmount'],
        totalAmount: map['totalAmount'],
        paymentMethod: map['paymentMethod'],
        status: map['status'],
        createdAt: map['createdAt'],
        customerName: map['customerName'],
        items: items,
      ));
    }
    return orders;
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('products');
    await db.delete('orders');
    await db.delete('order_items');
  }
}
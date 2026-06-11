import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:keen_pos/providers/cart_provider.dart';
import 'package:keen_pos/providers/product_provider.dart';
import 'package:keen_pos/screens/cart/cart_screen.dart';
import 'package:keen_pos/screens/tabs/products_tab.dart';
import 'package:keen_pos/screens/tabs/inventory_tab.dart';
import 'package:keen_pos/screens/tabs/orders_tab.dart';
import 'package:keen_pos/screens/tabs/dashboard_tab.dart';
import 'package:keen_pos/screens/tabs/settings_tab.dart';
import 'package:keen_pos/screens/tabs/home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<ProductProvider>().fetchProducts();
  }

  void _onTabChange(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(onTabChange: _onTabChange), // Pass the callback here
      const ProductsTab(),
      const InventoryTab(),
      const OrdersTab(),
      const DashboardTab(),
      const SettingsTab(),
    ];

    return Scaffold(
      body: tabs[_selectedIndex],
      floatingActionButton: _selectedIndex == 2
          ? null
          : Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                return FloatingActionButton(
                  backgroundColor: const Color(0xFF17A2B8),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                  child: Badge(
                    isLabelVisible: cartProvider.itemCount > 0,
                    label: Text(cartProvider.totalQuantity.toString()),
                    child: const Icon(Icons.shopping_cart_outlined, color: Colors.white),
                  ),
                );
              },
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabChange, // Use the callback here
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.home_outlined,
              color: _selectedIndex == 0 ? const Color(0xFF17A2B8) : Colors.grey,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.shopping_bag_outlined,
              color: _selectedIndex == 1 ? const Color(0xFF17A2B8) : Colors.grey,
            ),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.inventory_2_outlined,
              color: _selectedIndex == 2 ? const Color(0xFF17A2B8) : Colors.grey,
            ),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt_long_outlined,
              color: _selectedIndex == 3 ? const Color(0xFF17A2B8) : Colors.grey,
            ),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.bar_chart_outlined,
              color: _selectedIndex == 4 ? const Color(0xFF17A2B8) : Colors.grey,
            ),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings_outlined,
              color: _selectedIndex == 5 ? const Color(0xFF17A2B8) : Colors.grey,
            ),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:keen_pos/providers/auth_provider.dart';
import 'package:keen_pos/providers/dashboard_provider.dart';
import 'package:keen_pos/providers/order_provider.dart';
import 'package:keen_pos/models/models.dart';

class HomeTab extends StatefulWidget {
  final Function(int, {String? sectionId}) onTabChange; // Modified to accept sectionId

  const HomeTab({Key? key, required this.onTabChange}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchSalesReport(period: 'daily');
      context.read<OrderProvider>().fetchUserOrders(page: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final dashboardProvider = context.watch<DashboardProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final user = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF17A2B8).withOpacity(0.1),
              ),
              child: Center(
                child: user != null && user.profilePhotoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          user.profilePhotoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Text(
                            '${user.firstName[0]}${user.lastName[0]}'.toUpperCase(),
                            style: const TextStyle(
                              color: Color(0xFF17A2B8),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      )
                    : Text(
                        user != null
                            ? '${user.firstName[0]}${user.lastName[0]}'.toUpperCase()
                            : 'U',
                        style: const TextStyle(
                          color: Color(0xFF17A2B8),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.firstName ?? 'User'}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  DateFormat('EEEE, d MMMM').format(DateTime.now()),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await dashboardProvider.fetchSalesReport(period: 'daily');
          await orderProvider.fetchUserOrders(page: 0);
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Summary Section
              const Text(
                "Today's Summary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (dashboardProvider.isLoading && dashboardProvider.report == null)
                const Center(child: CircularProgressIndicator())
              else if (dashboardProvider.report != null)
                _TodaySummaryGrid(
                  report: dashboardProvider.report!,
                  onCardTap: widget.onTabChange, // Pass the onTabChange callback
                )
              else
                const Center(child: Text('No summary available')),

              const SizedBox(height: 24),

              // Recent Sales Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Sales',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => widget.onTabChange(3), // Switch to Orders tab (index 3)
                    child: const Text('View All'),
                  ),
                ],
              ),
              if (orderProvider.isLoading && orderProvider.orders.isEmpty)
                const Center(child: CircularProgressIndicator())
              else if (orderProvider.orders.isNotEmpty)
                _RecentSalesList(orders: orderProvider.orders.take(5).toList())
              else
                const Center(child: Text('No recent sales')),

              const SizedBox(height: 24),

              // Reports Link Section
              _MoreReportsCard(onTap: () => widget.onTabChange(4)), // Switch to Reports tab (index 4)
              
              const SizedBox(height: 80), // Space for bottom nav
            ],
          ),
        ),
      ),
    );
  }
}

class _TodaySummaryGrid extends StatelessWidget {
  final SalesReport report;
  final Function(int, {String? sectionId}) onCardTap; // Callback for card taps

  const _TodaySummaryGrid({required this.report, required this.onCardTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,##0");

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _SummaryCard(
          label: 'Today\'s Sales',
          value: 'Ksh.${currencyFormat.format(report.totalSales)}',
          icon: Icons.payments_outlined,
          gradient: const [Color(0xFF17A2B8), Color(0xFF117A8B)],
          shadowColor: const Color(0xFF17A2B8).withOpacity(0.3),
          onTap: () => onCardTap(4, sectionId: 'sales_profit_loss'), // Navigate to Reports tab, Sales section
        ),
        _SummaryCard(
          label: 'Today\'s Profit',
          value: 'Ksh.${currencyFormat.format(report.grossProfit)}',
          icon: Icons.trending_up,
          gradient: const [Color(0xFF28A745), Color(0xFF1E7E34)],
          shadowColor: const Color(0xFF28A745).withOpacity(0.3),
          onTap: () => onCardTap(4, sectionId: 'sales_profit_loss'), // Navigate to Reports tab, Profit section
        ),
        _SummaryCard(
          label: 'Orders',
          value: report.totalOrders.toString(),
          icon: Icons.receipt_long_outlined,
          gradient: const [Color(0xFF007BFF), Color(0xFF0062CC)],
          shadowColor: const Color(0xFF007BFF).withOpacity(0.3),
          onTap: () => onCardTap(3), // Navigate to Orders tab
        ),
        _SummaryCard(
          label: 'Items Sold',
          value: report.itemsSold.toString(),
          icon: Icons.inventory_2_outlined,
          gradient: const [Color(0xFF6F42C1), Color(0xFF59359A)],
          shadowColor: const Color(0xFF6F42C1).withOpacity(0.3),
          onTap: () => onCardTap(4, sectionId: 'summary_details'), // Navigate to Reports tab, Summary Details (Items Sold is part of this)
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final Color shadowColor;
  final VoidCallback? onTap; // Added onTap callback

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.shadowColor,
    this.onTap, // Initialize onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector( // Wrap with GestureDetector
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSalesList extends StatelessWidget {
  final List<Order> orders;

  const _RecentSalesList({required this.orders});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat("#,##0");

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF17A2B8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.receipt_outlined,
                  color: Color(0xFF17A2B8),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${order.items.length} items • ${order.paymentMethod}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                'Ksh.${currencyFormat.format(order.totalAmount)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MoreReportsCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MoreReportsCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF17A2B8), Color(0xFF0066CC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF17A2B8).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get Detailed Reports',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Analyze your business performance with advanced analytics.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
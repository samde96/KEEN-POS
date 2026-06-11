import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:keen_pos/models/models.dart';
import 'package:keen_pos/providers/dashboard_provider.dart';
import 'package:provider/provider.dart';

class DashboardTab extends StatefulWidget {
  const DashboardTab({Key? key}) : super(key: key);

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  static const _periods = ['daily', 'weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchSalesReport(period: 'weekly');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FDFF), // Very light themed background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Reports',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, dashboardProvider, _) {
          final report = dashboardProvider.report;

          if (dashboardProvider.isLoading && report == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (dashboardProvider.error != null && report == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  dashboardProvider.error!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (report == null) {
            return const Center(child: Text('No report data available'));
          }

          return RefreshIndicator(
            onRefresh: () => dashboardProvider.fetchSalesReport(),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                _PeriodSelector(
                  periods: _periods,
                  selectedPeriod: dashboardProvider.selectedPeriod,
                  onChanged: (period) {
                    dashboardProvider.fetchSalesReport(period: period);
                  },
                ),
                const SizedBox(height: 20),
                _ReportSummary(report: report),
                const SizedBox(height: 24),
                _SectionHeader(
                  title: 'Sales, Profit & Loss',
                  trailing: _periodLabel(report.period),
                ),
                const SizedBox(height: 12),
                _ChartPanel(
                  height: 280,
                  child: _SalesBarChart(report: report),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Trend Analysis',
                  trailing: 'Sales vs profit',
                ),
                const SizedBox(height: 12),
                _ChartPanel(
                  height: 240,
                  child: _SalesTrendChart(report: report),
                ),
                const SizedBox(height: 24),
                const _SectionHeader(
                  title: 'Product Performance',
                  trailing: 'Best & Least Selling',
                ),
                const SizedBox(height: 12),
                _ProductPerformanceSection(
                  bestSelling: report.bestSellingProducts,
                  leastSelling: report.leastSellingProducts,
                ),
                const SizedBox(height: 24),
                if (report.lowStockItems.isNotEmpty) ...[
                  const _SectionHeader(
                    title: 'Inventory Alerts',
                    trailing: 'Low stock items',
                  ),
                  const SizedBox(height: 12),
                  _LowStockList(items: report.lowStockItems),
                  const SizedBox(height: 24),
                ],
                const _SectionHeader(
                  title: 'Summary Details',
                  trailing: '',
                ),
                const SizedBox(height: 12),
                _ReportDetails(report: report),
              ],
            ),
          );
        },
      ),
    );
  }

  String _periodLabel(String period) {
    switch (period) {
      case 'daily':
        return 'Today by hour';
      case 'monthly':
        return 'This month';
      case 'yearly':
        return 'This year';
      default:
        return 'This week';
    }
  }
}

class _PeriodSelector extends StatelessWidget {
  final List<String> periods;
  final String selectedPeriod;
  final ValueChanged<String> onChanged;

  const _PeriodSelector({
    required this.periods,
    required this.selectedPeriod,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF17A2B8).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: periods.map((period) {
          final isSelected = selectedPeriod == period;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF17A2B8) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _titleCase(period),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[600],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _titleCase(String value) {
    return value.substring(0, 1).toUpperCase() + value.substring(1);
  }
}

class _ReportSummary extends StatelessWidget {
  final SalesReport report;

  const _ReportSummary({required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Total Sales',
                value: _money(report.totalSales),
                icon: Icons.point_of_sale_outlined,
                gradient: const [Color(0xFF17A2B8), Color(0xFF117A8B)],
                shadowColor: const Color(0xFF17A2B8).withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Total Profit',
                value: _money(report.grossProfit),
                icon: Icons.trending_up_outlined,
                gradient: const [Color(0xFF28A745), Color(0xFF1E7E34)],
                shadowColor: const Color(0xFF28A745).withOpacity(0.3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: 'Total Loss',
                value: _money(report.totalLoss),
                icon: Icons.trending_down_outlined,
                gradient: const [Color(0xFFDC3545), Color(0xFFBD2130)],
                shadowColor: const Color(0xFFDC3545).withOpacity(0.3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Total Orders',
                value: report.totalOrders.toString(),
                icon: Icons.receipt_long_outlined,
                gradient: const [Color(0xFF007BFF), Color(0xFF0062CC)],
                shadowColor: const Color(0xFF007BFF).withOpacity(0.3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final List<Color> gradient;
  final Color shadowColor;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.gradient,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
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
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const Icon(Icons.insights, color: Colors.white70, size: 20),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;

  const _SectionHeader({
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF134E5E)),
          ),
        ),
        Text(
          trailing,
          style: TextStyle(color: const Color(0xFF17A2B8).withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ChartPanel extends StatelessWidget {
  final double height;
  final Widget child;

  const _ChartPanel({
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.fromLTRB(10, 24, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF17A2B8).withOpacity(0.05), // Subtle themed tint
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF17A2B8).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _SalesBarChart extends StatelessWidget {
  final SalesReport report;

  const _SalesBarChart({required this.report});

  @override
  Widget build(BuildContext context) {
    final maxValue = report.data.fold<double>(
      0,
      (maxValue, point) => math.max(
        maxValue,
        math.max(point.sales, math.max(point.profit, point.loss)),
      ),
    );
    final maxY = maxValue <= 0 ? 100.0 : maxValue * 1.25;

    return BarChart(
      BarChartData(
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFF17A2B8).withOpacity(0.1),
            strokeWidth: 1,
          ),
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: const Color(0xFF134E5E),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = ['Sales', 'Profit', 'Loss'][rodIndex];
              return BarTooltipItem(
                '$label\n${_money(rod.toY)}',
                const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 46,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: TextStyle(color: const Color(0xFF17A2B8).withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 34,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= report.data.length) {
                  return const SizedBox.shrink();
                }
                if (!_shouldShowLabel(report.period, index)) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    report.data[index].label,
                    style: const TextStyle(color: Color(0xFF134E5E), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ),
        barGroups: report.data.asMap().entries.map((entry) {
          final point = entry.value;
          return BarChartGroupData(
            x: entry.key,
            barsSpace: 4,
            barRods: [
              BarChartRodData(
                toY: point.sales,
                width: 8,
                color: const Color(0xFF17A2B8),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: point.profit,
                width: 8,
                color: const Color(0xFF28A745),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              BarChartRodData(
                toY: point.loss,
                width: 8,
                color: const Color(0xFFDC3545),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SalesTrendChart extends StatelessWidget {
  final SalesReport report;

  const _SalesTrendChart({required this.report});

  @override
  Widget build(BuildContext context) {
    final maxValue = report.data.fold<double>(
      0,
      (maxValue, point) => math.max(maxValue, math.max(point.sales, point.profit)),
    );
    final maxY = maxValue <= 0 ? 100.0 : maxValue * 1.25;

    return LineChart(
      LineChartData(
        minY: 0,
        maxY: maxY,
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: const Color(0xFF17A2B8).withOpacity(0.1),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 46,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: TextStyle(color: const Color(0xFF17A2B8).withOpacity(0.6), fontSize: 10, fontWeight: FontWeight.bold),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= report.data.length) {
                  return const SizedBox.shrink();
                }
                if (!_shouldShowLabel(report.period, index)) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    report.data[index].label,
                    style: const TextStyle(color: Color(0xFF134E5E), fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: report.data
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(), entry.value.sales))
                .toList(),
            isCurved: true,
            barWidth: 4,
            color: const Color(0xFF17A2B8),
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF17A2B8).withOpacity(0.15),
            ),
          ),
          LineChartBarData(
            spots: report.data
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(), entry.value.profit))
                .toList(),
            isCurved: true,
            barWidth: 4,
            color: const Color(0xFF28A745),
            dotData: const FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _ProductPerformanceSection extends StatelessWidget {
  final List<ProductSalesData> bestSelling;
  final List<ProductSalesData> leastSelling;

  const _ProductPerformanceSection({
    required this.bestSelling,
    required this.leastSelling,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _PerformanceCard(
          title: 'Best Selling',
          items: bestSelling,
          color: const Color(0xFF28A745),
          icon: Icons.trending_up,
        ),
        const SizedBox(height: 12),
        _PerformanceCard(
          title: 'Least Selling',
          items: leastSelling,
          color: const Color(0xFFDC3545),
          icon: Icons.trending_down,
        ),
      ],
    );
  }
}

class _PerformanceCard extends StatelessWidget {
  final String title;
  final List<ProductSalesData> items;
  final Color color;
  final IconData icon;

  const _PerformanceCard({
    required this.title,
    required this.items,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.only(left: 12, bottom: 12),
              child: Text('No data available', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return ListTile(
                  dense: true,
                  title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${item.quantitySold} units sold'),
                  trailing: Text(
                    'Ksh. ${NumberFormat("#,##0").format(item.totalRevenue)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _LowStockList extends StatelessWidget {
  final List<Product> items;

  const _LowStockList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        children: items.map((product) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.orange.withOpacity(0.2),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
            ),
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(product.category),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${product.stockQuantity}',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text('left', style: TextStyle(fontSize: 10)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _ReportDetails extends StatelessWidget {
  final SalesReport report;

  const _ReportDetails({required this.report});

  @override
  Widget build(BuildContext context) {
    final rows = [
      _DetailRowData('Items sold', report.itemsSold.toString(), Icons.inventory_2_outlined, const Color(0xFF6C757D)),
      _DetailRowData('Average order', _money(report.averageOrderValue), Icons.analytics_outlined, const Color(0xFF17A2B8)),
      _DetailRowData('Cost of goods', _money(report.costOfGoods), Icons.request_quote_outlined, const Color(0xFFFFC107)),
      _DetailRowData('Discounts', _money(report.totalDiscounts), Icons.local_offer_outlined, const Color(0xFFFD7E14)),
      _DetailRowData('Tax collected', _money(report.totalTax), Icons.account_balance_outlined, const Color(0xFF6F42C1)),
    ];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF17A2B8).withOpacity(0.05), // Subtle themed tint
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF17A2B8).withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: rows.map((row) {
          final isLast = row == rows.last;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(color: const Color(0xFF17A2B8).withOpacity(0.1)),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: row.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(row.icon, color: row.color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    row.label,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF134E5E)),
                  ),
                ),
                Text(
                  row.value,
                  style: const TextStyle(color: Color(0xFF134E5E), fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _DetailRowData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  _DetailRowData(this.label, this.value, this.icon, this.color);
}

bool _shouldShowLabel(String period, int index) {
  switch (period) {
    case 'daily':
      return index % 4 == 0;
    case 'monthly':
      return index == 0 || (index + 1) % 5 == 0;
    default:
      return true;
  }
}

String _money(double value) {
  return 'Ksh. ${NumberFormat("#,##0").format(value)}';
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:keen_pos/providers/order_provider.dart';
import 'package:keen_pos/screens/home/home_screen.dart';
import 'package:keen_pos/models/models.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final double amountTendered;
  final double change;
  final String? paymentReference;
  final Order? order;

  const PaymentSuccessScreen({
    Key? key,
    required this.amountTendered,
    required this.change,
    this.paymentReference,
    this.order,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If order is not provided via constructor, try to get it from provider
    final displayOrder = order ?? context.read<OrderProvider>().lastOrder;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF17A2B8),
              const Color(0xFF0066CC),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Success Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.check_circle,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Success Message
                  const Text(
                    'Success!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Transaction Completed Successfully',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Order Details Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              displayOrder?.orderNumber ?? 'Receipt',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (displayOrder?.paymentMethod == 'MPESA')
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green[50],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'M-PESA',
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          displayOrder != null
                              ? 'Ksh. ${displayOrder.totalAmount.toStringAsFixed(2)}'
                              : 'Ksh. 0.00',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                          ),
                        ),
                        const Divider(height: 32),
                        _ReceiptLine(
                          label: 'Payment Method',
                          value: _paymentMethodName(displayOrder?.paymentMethod),
                        ),
                        if (displayOrder?.paymentMethod == 'MPESA' && displayOrder?.customerName != null)
                          _ReceiptLine(
                            label: 'Customer Name',
                            value: displayOrder!.customerName!,
                          ),
                        _ReceiptLine(
                          label: 'Amount Tendered',
                          value: 'Ksh. ${amountTendered.toStringAsFixed(2)}',
                        ),
                        _ReceiptLine(
                          label: 'Change',
                          value: 'Ksh. ${change.toStringAsFixed(2)}',
                        ),
                        if (paymentReference != null && paymentReference!.isNotEmpty)
                          _ReceiptLine(
                            label: 'Reference',
                            value: paymentReference!,
                          ),
                        const SizedBox(height: 24),
                        // Receipt Options
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              if (displayOrder == null) return;
                              _showReceiptDialog(context, displayOrder, amountTendered, change, paymentReference);
                            },
                            icon: const Icon(Icons.receipt_long),
                            label: const Text('View Full Receipt'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF17A2B8),
                              side: const BorderSide(color: Color(0xFF17A2B8)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Actions
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Printing receipt...')),
                            );
                          },
                          icon: const Icon(Icons.print),
                          label: const Text(
                            'Print Receipt',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF17A2B8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (_) => const HomeScreen()),
                              (route) => false,
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.white30),
                            ),
                          ),
                          child: const Text(
                            'Back Home',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, Order order, double amountTendered, double change, String? paymentReference) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Receipt Details'),
        content: SingleChildScrollView(
          child: _ReceiptDetails(
            order: order,
            amountTendered: amountTendered,
            change: change,
            paymentReference: paymentReference,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static String _paymentMethodName(String? method) {
    switch (method) {
      case 'CASH':
        return 'Cash';
      case 'MPESA':
        return 'M-Pesa';
      case 'CARD':
      case 'DEBIT':
        return 'Card';
      default:
        return method ?? 'Payment';
    }
  }
}

class _ReceiptLine extends StatelessWidget {
  final String label;
  final String value;

  const _ReceiptLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReceiptDetails extends StatelessWidget {
  final Order order;
  final double amountTendered;
  final double change;
  final String? paymentReference;

  const _ReceiptDetails({
    required this.order,
    required this.amountTendered,
    required this.change,
    this.paymentReference,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Column(
            children: [
              const Text('KEEN POS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              Text(order.orderNumber, style: const TextStyle(fontSize: 12)),
              Text(order.createdAt, style: const TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const Divider(height: 32),
        ...order.items.map<Widget>((item) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('${item.size} x ${item.quantity}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text('Ksh. ${item.subtotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          );
        }).toList(),
        const Divider(height: 32),
        _ReceiptLine(label: 'Subtotal', value: 'Ksh. ${order.subtotal.toStringAsFixed(2)}'),
        _ReceiptLine(label: 'Tax', value: 'Ksh. ${order.taxAmount.toStringAsFixed(2)}'),
        _ReceiptLine(label: 'Discount', value: 'Ksh. ${order.discountAmount.toStringAsFixed(2)}'),
        const Divider(height: 16),
        _ReceiptLine(label: 'TOTAL', value: 'Ksh. ${order.totalAmount.toStringAsFixed(2)}'),
        _ReceiptLine(label: 'Paid', value: 'Ksh. ${amountTendered.toStringAsFixed(2)}'),
        _ReceiptLine(label: 'Change', value: 'Ksh. ${change.toStringAsFixed(2)}'),
        if (order.paymentMethod == 'MPESA' && order.customerName != null)
          _ReceiptLine(label: 'M-Pesa Customer', value: order.customerName!),
        if (paymentReference != null && paymentReference!.isNotEmpty)
          _ReceiptLine(label: 'Reference', value: paymentReference!),
        const SizedBox(height: 16),
        const Center(
          child: Text('Thank you for shopping with us!', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
        ),
      ],
    );
  }
}
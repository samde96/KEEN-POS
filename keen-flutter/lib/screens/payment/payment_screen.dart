import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:keen_pos/providers/auth_provider.dart';
import 'package:keen_pos/providers/cart_provider.dart';
import 'package:keen_pos/providers/order_provider.dart';
import 'package:keen_pos/screens/auth/login_screen.dart';
import 'package:keen_pos/screens/payment/payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedPaymentMethod = 'CASH';
  final TextEditingController _cashReceivedController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  final List<PaymentMethod> paymentMethods = [
    PaymentMethod(
      id: 'CASH',
      name: 'Cash',
      icon: Icons.money,
    ),
    PaymentMethod(
      id: 'MPESA',
      name: 'M-Pesa',
      icon: Icons.phone_android,
    ),
    PaymentMethod(
      id: 'CARD',
      name: 'Card',
      icon: Icons.credit_card,
    ),
  ];

  @override
  void dispose() {
    _cashReceivedController.dispose();
    _referenceController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Payment',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // Items Summary
                Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Items',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...cartProvider.items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.product.name} (${item.size}) x${item.quantity}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                'Ksh.${item.subtotal.toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                // Payment Total
                Container(
                  color: Colors.grey[100],
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Sub Total'),
                          Text('Ksh.${cartProvider.subtotal.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tax (10%)'),
                          Text('Ksh.${cartProvider.tax.toStringAsFixed(2)}'),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: Colors.grey[400]),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Payment',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Ksh.${cartProvider.total.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF17A2B8),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Payment Method Selection
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Payment Method',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Choose any payment method.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.25,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: paymentMethods.length,
                        itemBuilder: (context, index) {
                          final method = paymentMethods[index];
                          final isSelected = selectedPaymentMethod == method.id;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedPaymentMethod = method.id),
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF0066CC)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF0066CC)
                                      : Colors.grey[300]!,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    method.icon,
                                    color: isSelected
                                        ? Colors.white
                                        : const Color(0xFF17A2B8),
                                    size: 24,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    method.name,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      if (selectedPaymentMethod == 'CASH')
                        TextField(
                          controller: _cashReceivedController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Cash Received',
                            prefixText: 'Ksh. ',
                            border: OutlineInputBorder(),
                          ),
                        )
                      else if (selectedPaymentMethod == 'MPESA')
                        Column(
                          children: [
                            TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'M-Pesa Phone Number',
                                hintText: 'e.g. 0712345678',
                                prefixIcon: Icon(Icons.phone),
                                border: OutlineInputBorder(),
                                helperText: 'An STK push will be sent to this number',
                              ),
                            ),
                          ],
                        )
                      else
                        TextField(
                          controller: _referenceController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Card Reference',
                            border: OutlineInputBorder(),
                          ),
                        ),
                    ],
                  ),
                ),
                // Payment Now Button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () => _processPayment(context, cartProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17A2B8),
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Consumer<OrderProvider>(
                        builder: (context, orderProvider, _) {
                          return orderProvider.isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Processing...',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Complete Sale',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _processPayment(
    BuildContext context,
    CartProvider cartProvider,
  ) async {
    final total = cartProvider.total;
    double? amountTendered;
    double change = 0;
    String? paymentReference;
    String? phoneNumber;

    if (selectedPaymentMethod == 'CASH') {
      amountTendered = double.tryParse(_cashReceivedController.text.trim());
      if (amountTendered == null || amountTendered < total) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter cash received equal to or above the total.')),
        );
        return;
      }
      change = amountTendered - total;
    } else if (selectedPaymentMethod == 'MPESA') {
      phoneNumber = _phoneController.text.trim();
      if (phoneNumber.isEmpty || phoneNumber.length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid M-Pesa phone number.')),
        );
        return;
      }
      amountTendered = total;
    } else {
      paymentReference = _referenceController.text.trim();
      if (paymentReference.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter the card reference.')),
        );
        return;
      }
      amountTendered = total;
    }

    final orderProvider = context.read<OrderProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    
    final orderData = cartProvider.getOrderData(selectedPaymentMethod);
    if (phoneNumber != null) {
      orderData['phoneNumber'] = phoneNumber;
    }

    final success = await orderProvider.createOrder(orderData);

    if (success && mounted) {
      cartProvider.clear();
      final lastOrder = orderProvider.lastOrder;
      
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => PaymentSuccessScreen(
            amountTendered: amountTendered!,
            change: change,
            paymentReference: lastOrder?.paymentMethod == 'MPESA' 
                ? lastOrder?.orderNumber // Using order number as ref if MPESA
                : paymentReference,
            order: lastOrder,
          ),
        ),
        (route) => false,
      );
    } else if (mounted) {
      if (orderProvider.error == 'Session expired. Please login again.') {
        await context.read<AuthProvider>().logout();
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
        return;
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(orderProvider.error ?? 'Payment failed. Please try again.'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final IconData icon;

  PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
  });
}
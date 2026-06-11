import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:keen_pos/providers/product_provider.dart';
import 'package:keen_pos/models/models.dart';

class InventoryTab extends StatefulWidget {
  const InventoryTab({Key? key}) : super(key: key);

  @override
  State<InventoryTab> createState() => _InventoryTabState();
}

class _InventoryTabState extends State<InventoryTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<ProductProvider>().fetchMetadata();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;
    final metadata = productProvider.metadata;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Inventory',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF17A2B8),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF17A2B8),
          tabs: const [
            Tab(text: 'Stock List'),
            Tab(text: 'Pricing & Profit'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Color(0xFF17A2B8)),
            onPressed: () => _showAddProductDialog(context, metadata),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Stock List
          _buildStockListTab(productProvider, products, metadata),
          // Tab 2: Pricing & Profit
          _buildPricingTab(productProvider, products),
        ],
      ),
    );
  }

  Widget _buildStockListTab(ProductProvider provider, List<Product> products, ProductMetadata? metadata) {
    return Column(
      children: [
        _buildSummaryHeader(provider, products),
        _buildSearchBar(provider),
        _buildTableHeader(['Product', 'Stock', 'Price']),
        Expanded(
          child: provider.isLoading && products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.fetchProducts(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: products.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _InventoryItem(
                        product: product,
                        showPricing: false,
                        onEdit: () => _showAddProductDialog(context, metadata, product: product),
                        onDelete: () => _confirmDelete(context, provider, product),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPricingTab(ProductProvider provider, List<Product> products) {
    return Column(
      children: [
        _buildSearchBar(provider),
        _buildTableHeader(['Product', 'Cost', 'Sell', 'Profit']),
        Expanded(
          child: provider.isLoading && products.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.fetchProducts(),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: products.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _InventoryItem(
                        product: product,
                        showPricing: true,
                        onEdit: () => _showAddProductDialog(context, provider.metadata, product: product),
                        onDelete: () => _confirmDelete(context, provider, product),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSummaryHeader(ProductProvider provider, List<Product> products) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          _SummaryItem(
            label: 'Total Items',
            value: provider.totalElements.toString(),
            color: Colors.blue,
          ),
          _SummaryItem(
            label: 'Low Stock',
            value: products.where((p) => p.stockQuantity < 10).length.toString(),
            color: Colors.orange,
          ),
          _SummaryItem(
            label: 'Out of Stock',
            value: products.where((p) => p.stockQuantity == 0).length.toString(),
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ProductProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => provider.searchProducts(value),
        decoration: InputDecoration(
          hintText: 'Search by SKU or Name...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeader(List<String> titles) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(titles[0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
          ...titles.sublist(1).map((t) => Expanded(
                child: Text(t, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              )),
          const SizedBox(width: 32),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, ProductMetadata? metadata, {Product? product}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ProductFormSheet(
        metadata: metadata,
        product: product,
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductProvider provider, Product product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final success = await provider.deleteProduct(product.id);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(success ? 'Deleted successfully' : 'Delete failed')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}

class _InventoryItem extends StatelessWidget {
  final Product product;
  final bool showPricing;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InventoryItem({
    required this.product,
    required this.showPricing,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (showPricing) {
      return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Text('Ksh ${product.costPrice.toStringAsFixed(0)}', textAlign: TextAlign.center),
            ),
            Expanded(
              child: Text('Ksh ${product.price.toStringAsFixed(0)}', textAlign: TextAlign.center),
            ),
            Expanded(
              child: Column(
                children: [
                  Text('Ksh ${(product.price - product.costPrice).toStringAsFixed(0)}', 
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  Text('${((product.price - product.costPrice) / product.price * 100).toStringAsFixed(1)}%', 
                    style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                ],
              ),
            ),
            _buildActionMenu(),
          ],
        ),
      );
    }

    final bool isLowStock = product.stockQuantity < 10;
    final bool isOutOfStock = product.stockQuantity == 0;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('${product.brand} • ${product.category}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              decoration: BoxDecoration(
                color: isOutOfStock ? Colors.red[50] : isLowStock ? Colors.orange[50] : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                product.stockQuantity.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isOutOfStock ? Colors.red : isLowStock ? Colors.orange : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text('Ksh ${product.price.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          _buildActionMenu(),
        ],
      ),
    );
  }

  Widget _buildActionMenu() {
    return PopupMenuButton(
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
      itemBuilder: (context) => [
        const PopupMenuItem(value: 'edit', child: Text('Edit')),
        const PopupMenuItem(value: 'delete', child: Text('Delete')),
      ],
      onSelected: (value) {
        if (value == 'edit') onEdit();
        if (value == 'delete') onDelete();
      },
    );
  }
}

class _ProductFormSheet extends StatefulWidget {
  final ProductMetadata? metadata;
  final Product? product;

  const _ProductFormSheet({this.metadata, this.product});

  @override
  State<_ProductFormSheet> createState() => _ProductFormSheetState();
}

class _ProductFormSheetState extends State<_ProductFormSheet> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;
  late TextEditingController _costController;
  late TextEditingController _stockController;
  late TextEditingController _categoryController;
  late TextEditingController _brandController;
  late TextEditingController _sizeController;
  late TextEditingController _colorController;
  
  List<String> _sizes = [];
  List<String> _colors = [];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name);
    _descController = TextEditingController(text: p?.description);
    _priceController = TextEditingController(text: p?.price.toString());
    _costController = TextEditingController(text: p?.costPrice.toString());
    _stockController = TextEditingController(text: p?.stockQuantity.toString());
    _categoryController = TextEditingController(text: p?.category);
    _brandController = TextEditingController(text: p?.brand);
    _sizeController = TextEditingController();
    _colorController = TextEditingController();
    _sizes = List.from(p?.sizes ?? []);
    _colors = List.from(p?.colors ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _stockController.dispose();
    _categoryController.dispose();
    _brandController.dispose();
    _sizeController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final metadata = widget.metadata;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      height: MediaQuery.of(context).size.height * 0.85,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product == null ? 'Add New Product' : 'Edit Product',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              _buildTextField(_nameController, 'Product Name'),
              const SizedBox(height: 12),
              _buildTextField(_descController, 'Description', maxLines: 3),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(_costController, 'Cost Price', prefix: 'Ksh. ')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(_priceController, 'Selling Price', prefix: 'Ksh. ')),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(_stockController, 'Initial Stock'),
              const SizedBox(height: 12),
              if (metadata != null) ...[
                _SuggestionField(controller: _categoryController, label: 'Category', suggestions: metadata.categories),
                const SizedBox(height: 12),
                _SuggestionField(controller: _brandController, label: 'Brand', suggestions: metadata.brands),
              ],
              const SizedBox(height: 20),
              _buildChipEditor(
                label: 'Available Sizes',
                controller: _sizeController,
                items: _sizes,
                suggestions: metadata?.sizes ?? [],
                onAdd: (val) => setState(() => _sizes.add(val)),
                onRemove: (val) => setState(() => _sizes.remove(val)),
              ),
              const SizedBox(height: 16),
              _buildChipEditor(
                label: 'Available Colors',
                controller: _colorController,
                items: _colors,
                suggestions: metadata?.colors ?? [],
                onAdd: (val) => setState(() => _colors.add(val)),
                onRemove: (val) => setState(() => _colors.remove(val)),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17A2B8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Save Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1, String? prefix}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: prefix != null || label.contains('Stock') ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
    );
  }

  Widget _buildChipEditor({
    required String label,
    required TextEditingController controller,
    required List<String> items,
    required List<String> suggestions,
    required ValueChanged<String> onAdd,
    required ValueChanged<String> onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ...items.map((item) => Chip(
                  label: Text(item),
                  onDeleted: () => onRemove(item),
                  deleteIcon: const Icon(Icons.close, size: 14),
                )),
            ActionChip(
              label: const Icon(Icons.add, size: 18),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Add $label'),
                    content: TextField(
                      controller: controller,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'Enter value'),
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      TextButton(
                        onPressed: () {
                          if (controller.text.isNotEmpty) {
                            onAdd(controller.text.trim());
                            controller.clear();
                          }
                          Navigator.pop(context);
                        },
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final productData = {
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'price': double.parse(_priceController.text),
        'costPrice': double.parse(_costController.text),
        'stockQuantity': int.parse(_stockController.text),
        'category': _categoryController.text.trim(),
        'brand': _brandController.text.trim(),
        'sizes': _sizes,
        'colors': _colors,
      };

      final provider = context.read<ProductProvider>();
      final success = widget.product == null
          ? await provider.createProduct(productData)
          : await provider.updateProduct(widget.product!.id, productData);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(success ? 'Saved successfully' : 'Failed to save')),
        );
      }
    }
  }
}

class _SuggestionField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final List<String> suggestions;

  const _SuggestionField({required this.controller, required this.label, required this.suggestions});

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text == '') return const Iterable<String>.empty();
        return suggestions.where((String option) => option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) => controller.text = selection,
      fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
        if (controller.text.isNotEmpty && fieldController.text.isEmpty) fieldController.text = controller.text;
        return TextFormField(
          controller: fieldController,
          focusNode: focusNode,
          onChanged: (val) => controller.text = val,
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[50],
          ),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        );
      },
    );
  }
}
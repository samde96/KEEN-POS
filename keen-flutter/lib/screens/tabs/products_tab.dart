import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:keen_pos/providers/product_provider.dart';
import 'package:keen_pos/providers/cart_provider.dart';
import 'package:keen_pos/models/models.dart';
import 'package:keen_pos/screens/product/product_detail_screen.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({Key? key}) : super(key: key);

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().fetchProducts();
      context.read<ProductProvider>().fetchMetadata();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Products',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF17A2B8)),
            onPressed: () => _showFilterSheet(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                context.read<ProductProvider>().searchProducts(value);
              },
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<ProductProvider>().clearFilters();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          // Active Filters
          const _ActiveFiltersBar(),
          // Product Grid
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.products.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null && provider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(provider.error!),
                        ElevatedButton(
                          onPressed: () => provider.fetchProducts(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.products.isEmpty) {
                  return const Center(child: Text('No products found'));
                }

                return RefreshIndicator(
                  onRefresh: () => provider.fetchProducts(),
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: provider.products.length,
                    itemBuilder: (context, index) {
                      return _ProductCard(product: provider.products[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _FilterSheet(),
    );
  }
}

class _ActiveFiltersBar extends StatelessWidget {
  const _ActiveFiltersBar();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final List<MapEntry<String, String>> activeFilters = [];
        if (provider.selectedCategory != null) activeFilters.add(MapEntry('Category', provider.selectedCategory!));
        if (provider.selectedBrand != null) activeFilters.add(MapEntry('Brand', provider.selectedBrand!));
        if (provider.selectedSize != null) activeFilters.add(MapEntry('Size', provider.selectedSize!));
        if (provider.selectedColor != null) activeFilters.add(MapEntry('Color', provider.selectedColor!));

        if (activeFilters.isEmpty) return const SizedBox.shrink();

        return SizedBox(
          height: 50,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            children: [
              TextButton(
                onPressed: () => provider.clearFilters(),
                child: const Text('Clear All'),
              ),
              const SizedBox(width: 8),
              ...activeFilters.map((entry) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Chip(
                      label: Text('${entry.key}: ${entry.value}', style: const TextStyle(fontSize: 12)),
                      onDeleted: () {
                        provider.applyFilters(
                          category: entry.key == 'Category' ? null : provider.selectedCategory,
                          brand: entry.key == 'Brand' ? null : provider.selectedBrand,
                          size: entry.key == 'Size' ? null : provider.selectedSize,
                          color: entry.key == 'Color' ? null : provider.selectedColor,
                        );
                      },
                      deleteIcon: const Icon(Icons.close, size: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      backgroundColor: const Color(0xFF17A2B8).withOpacity(0.1),
                      side: BorderSide.none,
                    ),
                  )),
            ],
          ),
        );
      },
    );
  }
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        final metadata = provider.metadata;
        
        return Container(
          padding: const EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      provider.clearFilters();
                      Navigator.pop(context);
                    },
                    child: const Text('Reset'),
                  ),
                ],
              ),
              const Divider(),
              if (metadata == null)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFilterSection(
                          title: 'Category',
                          options: metadata.categories,
                          selected: provider.selectedCategory,
                          onSelected: (val) => provider.applyFilters(
                            category: val,
                            brand: provider.selectedBrand,
                            size: provider.selectedSize,
                            color: provider.selectedColor,
                          ),
                        ),
                        _buildFilterSection(
                          title: 'Brand',
                          options: metadata.brands,
                          selected: provider.selectedBrand,
                          onSelected: (val) => provider.applyFilters(
                            category: provider.selectedCategory,
                            brand: val,
                            size: provider.selectedSize,
                            color: provider.selectedColor,
                          ),
                        ),
                        _buildFilterSection(
                          title: 'Size',
                          options: metadata.sizes,
                          selected: provider.selectedSize,
                          onSelected: (val) => provider.applyFilters(
                            category: provider.selectedCategory,
                            brand: provider.selectedBrand,
                            size: val,
                            color: provider.selectedColor,
                          ),
                        ),
                        _buildFilterSection(
                          title: 'Color',
                          options: metadata.colors,
                          selected: provider.selectedColor,
                          onSelected: (val) => provider.applyFilters(
                            category: provider.selectedCategory,
                            brand: provider.selectedBrand,
                            size: provider.selectedSize,
                            color: val,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF17A2B8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> options,
    required String? selected,
    required ValueChanged<String?> onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ),
        Wrap(
          spacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                onSelected(selected ? option : null);
              },
              selectedColor: const Color(0xFF17A2B8),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(productId: product.id),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Center(
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                        )
                      : const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
              ),
            ),
            // Product Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.category,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ksh. ${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF17A2B8),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.read<CartProvider>().addItem(
                                product,
                                1,
                                product.sizes.isNotEmpty ? product.sizes[0] : 'Standard',
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Added to cart'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF17A2B8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
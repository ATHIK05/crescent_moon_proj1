import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pharmacy_provider.dart';
import '../../models/pharmacy_model.dart';
import '../../widgets/empty_state.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'pharmacy_orders_screen.dart';

class PharmacyScreen extends StatefulWidget {
  const PharmacyScreen({super.key});

  @override
  State<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends State<PharmacyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy'),
        actions: [
          Consumer<PharmacyProvider>(
            builder: (context, pharmacyProvider, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  if (pharmacyProvider.cartItemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${pharmacyProvider.cartItemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Products'),
            Tab(text: 'Orders'),
            Tab(text: 'Loyalty'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildProductsTab(),
          const PharmacyOrdersScreen(),
          _buildLoyaltyTab(),
        ],
      ),
    );
  }

  Widget _buildProductsTab() {
    return Column(
      children: [
        // Search Bar
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search medicines, health products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        Provider.of<PharmacyProvider>(context, listen: false)
                            .searchProducts('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              Provider.of<PharmacyProvider>(context, listen: false)
                  .searchProducts(value);
            },
          ),
        ),

        // Categories
        Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Consumer<PharmacyProvider>(
            builder: (context, pharmacyProvider, child) {
              return ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryChip('All', null, pharmacyProvider),
                  const SizedBox(width: 8),
                  ...ProductCategory.values.map((category) =>
                      _buildCategoryChip(
                        _getCategoryText(category),
                        category,
                        pharmacyProvider,
                      )),
                ],
              );
            },
          ),
        ),

        // Products Grid
        Expanded(
          child: Consumer<PharmacyProvider>(
            builder: (context, pharmacyProvider, child) {
              if (pharmacyProvider.filteredProducts.isEmpty) {
                return const EmptyState(
                  icon: Icons.local_pharmacy,
                  title: 'No Products Found',
                  message: 'Try adjusting your search or browse different categories.',
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  // Refresh products
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.75,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: pharmacyProvider.filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = pharmacyProvider.filteredProducts[index];
                    return _buildProductCard(context, product);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(String label, ProductCategory? category, PharmacyProvider provider) {
    final isSelected = provider.selectedCategory == category;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => provider.filterByCategory(isSelected ? null : category),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildProductCard(BuildContext context, PharmacyProductModel product) {
    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: product),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.medical_services, size: 40);
                          },
                        ),
                      )
                    : const Icon(Icons.medical_services, size: 40),
              ),
            ),
            
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.hasDiscount) ...[
                      Row(
                        children: [
                          Text(
                            'AED ${product.price.toStringAsFixed(0)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${product.discountPercentage}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'AED ${product.finalPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
                      Text(
                        'AED ${product.finalPrice.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (product.isPrescriptionRequired)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Prescription Required',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoyaltyTab() {
    return Consumer<PharmacyProvider>(
      builder: (context, pharmacyProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loyalty Points Card
              Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.stars,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Your Loyalty Points',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${pharmacyProvider.loyaltyPoints}',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Points = AED ${(pharmacyProvider.loyaltyPoints * 0.1).toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // How it works
              Text(
                'How Loyalty Points Work',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildLoyaltyInfoCard(
                Icons.shopping_cart,
                'Earn Points',
                'Get 1 point for every AED spent on pharmacy orders',
              ),
              _buildLoyaltyInfoCard(
                Icons.redeem,
                'Redeem Points',
                '10 points = AED 1 discount on your next order',
              ),
              _buildLoyaltyInfoCard(
                Icons.card_giftcard,
                'Special Offers',
                'Exclusive deals and discounts for loyal customers',
              ),
              const SizedBox(height: 24),
              
              // Recent Orders
              Text(
                'Recent Orders',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (pharmacyProvider.orders.isEmpty)
                const EmptyState(
                  icon: Icons.receipt,
                  title: 'No Orders Yet',
                  message: 'Your pharmacy orders will appear here.',
                )
              else
                ...pharmacyProvider.orders.take(3).map((order) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.local_pharmacy,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text('Order #${order.id.substring(0, 8)}'),
                    subtitle: Text('${order.items.length} items • ${order.statusText}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'AED ${order.totalAmount.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (order.loyaltyPointsEarned > 0)
                          Text(
                            '+${order.loyaltyPointsEarned} pts',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.green,
                            ),
                          ),
                      ],
                    ),
                  ),
                )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoyaltyInfoCard(IconData icon, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getCategoryText(ProductCategory category) {
    switch (category) {
      case ProductCategory.medicines:
        return 'Medicines';
      case ProductCategory.vitamins:
        return 'Vitamins';
      case ProductCategory.supplements:
        return 'Supplements';
      case ProductCategory.skincare:
        return 'Skincare';
      case ProductCategory.personalCare:
        return 'Personal Care';
      case ProductCategory.babycare:
        return 'Baby Care';
      case ProductCategory.fitness:
        return 'Fitness';
      case ProductCategory.medicalDevices:
        return 'Medical Devices';
      case ProductCategory.firstAid:
        return 'First Aid';
      case ProductCategory.wellness:
        return 'Wellness';
    }
  }
}
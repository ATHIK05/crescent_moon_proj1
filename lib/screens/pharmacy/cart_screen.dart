import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/pharmacy_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/custom_button.dart';
import 'checkout_screen.dart';
import '../../models/pharmacy_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
        actions: [
          Consumer<PharmacyProvider>(
            builder: (context, pharmacyProvider, child) {
              if (pharmacyProvider.cartItems.isNotEmpty) {
                return TextButton(
                  onPressed: () {
                    _showClearCartDialog(context, pharmacyProvider);
                  },
                  child: const Text('Clear All'),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Consumer<PharmacyProvider>(
        builder: (context, pharmacyProvider, child) {
          if (pharmacyProvider.cartItems.isEmpty) {
            return const EmptyState(
              icon: Icons.shopping_cart_outlined,
              title: 'Your Cart is Empty',
              message: 'Add some products to your cart to get started.',
              actionText: 'Browse Products',
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: pharmacyProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final item = pharmacyProvider.cartItems[index];
                    return _buildCartItem(context, item, pharmacyProvider);
                  },
                ),
              ),
              _buildCartSummary(context, pharmacyProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, CartItemModel item, PharmacyProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.medical_services);
                        },
                      ),
                    )
                  : const Icon(Icons.medical_services),
            ),
            const SizedBox(width: 16),
            
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'AED ${item.price.toStringAsFixed(2)} each',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  if (item.isPrescriptionRequired) ...[
                    const SizedBox(height: 4),
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
                ],
              ),
            ),
            
            // Quantity Controls
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (item.quantity > 1) {
                          provider.updateCartItemQuantity(item.productId, item.quantity - 1);
                        } else {
                          provider.removeFromCart(item.productId);
                        }
                      },
                      icon: Icon(
                        item.quantity > 1 ? Icons.remove : Icons.delete,
                        size: 20,
                      ),
                    ),
                    Text(
                      '${item.quantity}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      onPressed: () {
                        provider.updateCartItemQuantity(item.productId, item.quantity + 1);
                      },
                      icon: const Icon(Icons.add, size: 20),
                    ),
                  ],
                ),
                Text(
                  'AED ${item.totalPrice.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, PharmacyProvider provider) {
    final subtotal = provider.cartTotal;
    final deliveryFee = subtotal > 100 ? 0.0 : 15.0;
    final total = subtotal + deliveryFee;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                'AED ${subtotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivery Fee',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                deliveryFee == 0 ? 'FREE' : 'AED ${deliveryFee.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: deliveryFee == 0 ? Colors.green : null,
                ),
              ),
            ],
          ),
          if (subtotal < 100) ...[
            const SizedBox(height: 4),
            Text(
              'Free delivery on orders over AED 100',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'AED ${total.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Proceed to Checkout',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const CheckoutScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context, PharmacyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cart'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.clearCart();
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
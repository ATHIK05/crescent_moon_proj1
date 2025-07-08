import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/pharmacy_provider.dart';
import '../../models/pharmacy_model.dart';
import '../../widgets/empty_state.dart';

class PharmacyOrdersScreen extends StatelessWidget {
  const PharmacyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PharmacyProvider>(
      builder: (context, pharmacyProvider, child) {
        if (pharmacyProvider.orders.isEmpty) {
          return const EmptyState(
            icon: Icons.receipt,
            title: 'No Orders Yet',
            message: 'Your pharmacy orders will appear here.',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Refresh orders
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pharmacyProvider.orders.length,
            itemBuilder: (context, index) {
              final order = pharmacyProvider.orders[index];
              return _buildOrderCard(context, order, pharmacyProvider);
            },
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, PharmacyOrderModel order, PharmacyProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('MMM d, y - h:mm a').format(order.orderDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.statusText,
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Order Items
            Text(
              'Items (${order.items.length})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ...order.items.take(3).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${item.productName} x${item.quantity}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  Text(
                    'AED ${item.totalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            )),
            if (order.items.length > 3) ...[
              const SizedBox(height: 4),
              Text(
                '+${order.items.length - 3} more items',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: 16),
            
            // Delivery Info
            if (order.estimatedDeliveryDate != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimated Delivery: ${DateFormat('MMM d, y').format(order.estimatedDeliveryDate!)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            if (order.trackingNumber != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.track_changes,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tracking: ${order.trackingNumber}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            
            // Total and Actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total: AED ${order.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      if (order.loyaltyPointsEarned > 0)
                        Text(
                          'Earned ${order.loyaltyPointsEarned} loyalty points',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                          ),
                        ),
                    ],
                  ),
                ),
                if (order.canCancel)
                  OutlinedButton(
                    onPressed: () => _showCancelDialog(context, order, provider),
                    child: const Text('Cancel'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.purple;
      case OrderStatus.shipped:
        return Colors.indigo;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.returned:
        return Colors.grey;
    }
  }

  void _showCancelDialog(BuildContext context, PharmacyOrderModel order, PharmacyProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel order #${order.id.substring(0, 8)}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await provider.cancelOrder(order.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Order cancelled successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
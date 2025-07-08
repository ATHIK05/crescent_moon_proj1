import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/billing_provider.dart';
import '../../widgets/empty_state.dart';
import '../../models/bill_model.dart';
import 'bill_detail_screen.dart';

class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills & Payments'),
      ),
      body: Consumer<BillingProvider>(
        builder: (context, billingProvider, child) {
          if (billingProvider.bills.isEmpty) {
            return const EmptyState(
              icon: Icons.receipt,
              title: 'No Bills',
              message: 'Your bills and payment history will appear here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh bills
            },
            child: Column(
              children: [
                if (billingProvider.pendingBills.isNotEmpty) ...[
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Outstanding Balance',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                ),
                              ),
                              Text(
                                '\$${billingProvider.totalPendingAmount.toStringAsFixed(2)}',
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: billingProvider.bills.length,
                    itemBuilder: (context, index) {
                      final bill = billingProvider.bills[index];
                      return _buildBillCard(context, bill);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBillCard(BuildContext context, BillModel bill) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BillDetailScreen(bill: bill),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
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
                          'Bill #${bill.billNumber}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bill.typeText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${bill.totalAmount.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: bill.isPaid ? Colors.green : Theme.of(context).colorScheme.error,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(bill.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          bill.statusText,
                          style: TextStyle(
                            color: _getStatusColor(bill.status),
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Bill Date: ${DateFormat('MMM d, y').format(bill.billDate)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Due Date: ${DateFormat('MMM d, y').format(bill.dueDate)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: bill.isOverdue ? Theme.of(context).colorScheme.error : null,
                    ),
                  ),
                ],
              ),
              if (bill.paidDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Paid on ${DateFormat('MMM d, y').format(bill.paidDate!)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
              if (bill.status == BillStatus.pending) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showPaymentDialog(context, bill),
                    child: const Text('Pay Now'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(BillStatus status) {
    switch (status) {
      case BillStatus.pending:
        return Colors.orange;
      case BillStatus.paid:
        return Colors.green;
      case BillStatus.overdue:
        return Colors.red;
      case BillStatus.cancelled:
        return Colors.grey;
    }
  }

  void _showPaymentDialog(BuildContext context, BillModel bill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment'),
        content: Text('This would integrate with a payment gateway to process the payment of \$${bill.totalAmount.toStringAsFixed(2)}.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment gateway integration coming soon'),
                ),
              );
            },
            child: const Text('Proceed'),
          ),
        ],
      ),
    );
  }
}
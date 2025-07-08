import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/bill_model.dart';

class BillDetailScreen extends StatelessWidget {
  final BillModel bill;

  const BillDetailScreen({
    super.key,
    required this.bill,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill #${bill.billNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Bill #${bill.billNumber}',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(bill.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            bill.statusText,
                            style: TextStyle(
                              color: _getStatusColor(bill.status),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      bill.typeText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      context,
                      'Bill Date',
                      DateFormat('MMMM d, y').format(bill.billDate),
                    ),
                    _buildInfoRow(
                      context,
                      'Due Date',
                      DateFormat('MMMM d, y').format(bill.dueDate),
                    ),
                    if (bill.paidDate != null)
                      _buildInfoRow(
                        context,
                        'Paid Date',
                        DateFormat('MMMM d, y').format(bill.paidDate!),
                      ),
                    if (bill.paymentMethod != null)
                      _buildInfoRow(
                        context,
                        'Payment Method',
                        bill.paymentMethod!,
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill Items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...bill.items.map((item) => _buildItemRow(context, item)),
                    const Divider(),
                    _buildSummaryRow(context, 'Subtotal', bill.subtotal),
                    if (bill.discount > 0)
                      _buildSummaryRow(context, 'Discount', -bill.discount),
                    if (bill.tax > 0)
                      _buildSummaryRow(context, 'Tax', bill.tax),
                    const Divider(),
                    _buildSummaryRow(
                      context,
                      'Total',
                      bill.totalAmount,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
            ),
            if (bill.notes != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bill.notes!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (bill.status == BillStatus.pending) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _showPaymentDialog(context),
                  child: Text('Pay \$${bill.totalAmount.toStringAsFixed(2)}'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, BillItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  'Qty: ${item.quantity} × \$${item.amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '\$${item.total.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: isTotal
                  ? Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  : Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : Theme.of(context).textTheme.bodyMedium,
          ),
        ],
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

  void _showPaymentDialog(BuildContext context) {
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
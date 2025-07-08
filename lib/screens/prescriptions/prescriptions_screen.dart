import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/prescription_provider.dart';
import '../../widgets/empty_state.dart';
import '../../models/prescription_model.dart';
import 'prescription_detail_screen.dart';

class PrescriptionsScreen extends StatelessWidget {
  const PrescriptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescriptions'),
      ),
      body: Consumer<PrescriptionProvider>(
        builder: (context, prescriptionProvider, child) {
          if (prescriptionProvider.prescriptions.isEmpty) {
            return const EmptyState(
              icon: Icons.medication,
              title: 'No Prescriptions',
              message: 'Your prescriptions will appear here when prescribed by your doctor.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh prescriptions
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prescriptionProvider.prescriptions.length,
              itemBuilder: (context, index) {
                final prescription = prescriptionProvider.prescriptions[index];
                return _buildPrescriptionCard(context, prescription);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrescriptionCard(BuildContext context, PrescriptionModel prescription) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PrescriptionDetailScreen(prescription: prescription),
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
                          'Dr. ${prescription.doctorName}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('MMMM d, y').format(prescription.prescribedDate),
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
                      color: _getStatusColor(prescription.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      prescription.statusText,
                      style: TextStyle(
                        color: _getStatusColor(prescription.status),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Medications (${prescription.medications.length})',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ...prescription.medications.take(2).map((medication) => Padding(
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
                        '${medication.name} - ${medication.dosage}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              )),
              if (prescription.medications.length > 2) ...[
                const SizedBox(height: 4),
                Text(
                  '+${prescription.medications.length - 2} more medications',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
              if (prescription.canRequestRenewal) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _requestRenewal(context, prescription),
                    child: const Text('Request Renewal'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(PrescriptionStatus status) {
    switch (status) {
      case PrescriptionStatus.active:
        return Colors.green;
      case PrescriptionStatus.completed:
        return Colors.grey;
      case PrescriptionStatus.cancelled:
        return Colors.red;
      case PrescriptionStatus.renewalRequested:
        return Colors.orange;
    }
  }

  void _requestRenewal(BuildContext context, PrescriptionModel prescription) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Request Renewal'),
        content: const Text('Are you sure you want to request a renewal for this prescription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final prescriptionProvider = Provider.of<PrescriptionProvider>(
                context,
                listen: false,
              );
              final success = await prescriptionProvider.requestRenewal(prescription.id);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Renewal request sent successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Request'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/consultation_provider.dart';
import '../../widgets/empty_state.dart';
import '../../models/consultation_model.dart';
import 'consultation_detail_screen.dart';

class ConsultationsScreen extends StatelessWidget {
  const ConsultationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultations'),
      ),
      body: Consumer<ConsultationProvider>(
        builder: (context, consultationProvider, child) {
          if (consultationProvider.consultations.isEmpty) {
            return const EmptyState(
              icon: Icons.medical_services,
              title: 'No Consultations',
              message: 'Your consultation history will appear here after your appointments.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh consultations
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: consultationProvider.consultations.length,
              itemBuilder: (context, index) {
                final consultation = consultationProvider.consultations[index];
                return _buildConsultationCard(context, consultation);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildConsultationCard(BuildContext context, ConsultationModel consultation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ConsultationDetailScreen(consultation: consultation),
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
                          'Dr. ${consultation.doctorName}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          consultation.doctorSpecialty,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (consultation.hasReport)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.description,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
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
                    DateFormat('EEEE, MMMM d, y').format(consultation.consultationDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.medical_information,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      consultation.diagnosis,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (consultation.hasFollowUp) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.event_note,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Follow-up: ${DateFormat('MMM d, y').format(consultation.nextAppointment!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
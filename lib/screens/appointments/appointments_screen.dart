import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;
import '../../widgets/empty_state.dart';
import '../../models/appointment_model.dart';
import 'book_appointment_screen.dart';
import 'appointment_detail_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    tzdata.initializeTimeZones();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BookAppointmentScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: userId == null
          ? const Center(child: Text('User not logged in'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('appointments')
                  .where('patientId', isEqualTo: userId)
                  .orderBy('appointmentDate', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return TabBarView(
                    controller: _tabController,
                    children: [
                      EmptyState(
                        icon: Icons.calendar_today,
                        title: 'No upcoming appointments',
                        message: 'Your upcoming appointments will appear here.',
                        actionText: 'Book Appointment',
                        onAction: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const BookAppointmentScreen(),
                            ),
                          );
                        },
                      ),
                      EmptyState(
                        icon: Icons.calendar_today,
                        title: 'No past appointments',
                        message: 'Your appointment history will appear here.',
                      ),
                    ],
                  );
                }

                // Always get the current time here!
                final ist = tz.getLocation('Asia/Kolkata');
                final now = tz.TZDateTime.from(DateTime.now(), ist);
                final appointments = snapshot.data!.docs
                    .map((doc) => AppointmentModel.fromFirestore(doc))
                    .toList();

                List<AppointmentModel> upcoming = [];
                List<AppointmentModel> past = [];

                for (final apt in appointments) {
                  DateTime start = apt.appointmentDate;
                  DateTime end = start;

                  // Robustly parse end time from timeSlot (e.g. "9:45 AM - 10:00 AM" or "9 PM - 10 PM")
                  final match = RegExp(r'(\d{1,2}(?::\d{2})?\s*[AP]M)\s*-\s*(\d{1,2}(?::\d{2})?\s*[AP]M)').firstMatch(apt.timeSlot);
                  if (match != null) {
                    final endTimeStr = match.group(2)!; // e.g. "10:00 AM" or "10 PM"
                    final timeFormat = endTimeStr.contains(':')
                        ? DateFormat('h:mm a')
                        : DateFormat('h a');
                    final parsedEnd = timeFormat.parse(endTimeStr);

                    // Set end time on the same day as appointmentDate
                    end = DateTime(
                      start.year,
                      start.month,
                      start.day,
                      parsedEnd.hour,
                      parsedEnd.minute,
                    );
                  }

                  // Convert to IST for comparison
                  final endIST = tz.TZDateTime.from(end, ist);
                  if (endIST.isAfter(now)) {
                    upcoming.add(apt);
                  } else {
                    past.add(apt);
                  }
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAnimatedAppointmentsList(
                      upcoming,
                      'No upcoming appointments',
                      'Your upcoming appointments will appear here.',
                      true,
                      key: const PageStorageKey('upcoming'),
                    ),
                    _buildAppointmentsList(
                      past,
                      'No past appointments',
                      'Your appointment history will appear here.',
                      false,
                      key: const PageStorageKey('past'),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const BookAppointmentScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnimatedAppointmentsList(
    List<AppointmentModel> appointments,
    String emptyTitle,
    String emptyMessage,
    bool showActions, {
    Key? key,
  }) {
    return RefreshIndicator(
      onRefresh: () async {
        // No-op, as StreamBuilder is real-time
      },
      child: appointments.isEmpty
          ? EmptyState(
              icon: Icons.calendar_today,
              title: emptyTitle,
              message: emptyMessage,
              actionText: showActions ? 'Book Appointment' : null,
              onAction: showActions
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BookAppointmentScreen(),
                        ),
                      );
                    }
                  : null,
            )
          : _AnimatedAppointmentListView(
              appointments: appointments,
              showActions: showActions,
              buildCard: (apt) => _buildAppointmentCard(apt, showActions),
              key: key,
            ),
    );
  }

  Widget _buildAppointmentsList(
    List<AppointmentModel> appointments,
    String emptyTitle,
    String emptyMessage,
    bool showActions, {
    Key? key,
  }) {
    if (appointments.isEmpty) {
      return EmptyState(
        icon: Icons.calendar_today,
        title: emptyTitle,
        message: emptyMessage,
        actionText: showActions ? 'Book Appointment' : null,
        onAction: showActions
            ? () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BookAppointmentScreen(),
                  ),
                );
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // No-op, as StreamBuilder is real-time
      },
      child: ListView.separated(
        key: key,
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(appointment, showActions);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(AppointmentModel appointment, bool showActions) {
    final statusColor = _getStatusColor(appointment.status);
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AppointmentDetailScreen(appointment: appointment),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appointment.doctorName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          appointment.doctorSpecialty,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      appointment.statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _iconWithBg(Icons.calendar_today, Theme.of(context).colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(appointment.appointmentDate),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _iconWithBg(Icons.access_time, Colors.deepPurple),
                  const SizedBox(width: 8),
                  Text(
                    appointment.timeSlot,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _iconWithBg(Icons.medical_services, Colors.teal),
                  const SizedBox(width: 8),
                  Text(
                    appointment.typeText,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              if (appointment.reason != null) ...[
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _iconWithBg(Icons.note, Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.reason!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ],
              if (showActions && appointment.status != AppointmentStatus.cancelled) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _showCancelDialog(appointment),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showRescheduleDialog(appointment),
                        child: const Text('Reschedule'),
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

  Widget _iconWithBg(IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.all(6),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.green;
      case AppointmentStatus.completed:
        return Colors.grey;
      case AppointmentStatus.cancelled:
        return Colors.red;
      case AppointmentStatus.rescheduled:
        return Colors.orange;
    }
  }

  void _showCancelDialog(AppointmentModel appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Implement cancellation logic if needed
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Appointment cancelled (demo)'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _showRescheduleDialog(AppointmentModel appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reschedule feature coming soon'),
      ),
    );
  }
}

class _AnimatedAppointmentListView extends StatefulWidget {
  final List<AppointmentModel> appointments;
  final bool showActions;
  final Widget Function(AppointmentModel) buildCard;

  const _AnimatedAppointmentListView({
    required this.appointments,
    required this.showActions,
    required this.buildCard,
    Key? key,
  }) : super(key: key);

  @override
  State<_AnimatedAppointmentListView> createState() => _AnimatedAppointmentListViewState();
}

class _AnimatedAppointmentListViewState extends State<_AnimatedAppointmentListView> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasAnimated) {
        _controller.forward();
        _hasAnimated = true;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: widget.appointments.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final appointment = widget.appointments[index];
            return widget.buildCard(appointment);
          },
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/billing_provider.dart';
import '../../providers/consultation_provider.dart';
import '../../providers/pharmacy_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/recent_activity_item.dart';
import '../../widgets/empty_state.dart';
import '../appointments/appointments_screen.dart';
import '../prescriptions/prescriptions_screen.dart';
import '../billing/billing_screen.dart';
import '../consultations/consultations_screen.dart';
import '../messaging/messaging_screen.dart';
import '../doctors/doctors_screen.dart';
import '../pharmacy/pharmacy_screen.dart';
import '../family/family_screen.dart';
import '../medical_records/medical_records_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AppointmentsScreen(),
    const DoctorsScreen(),
    const PharmacyScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_search),
            label: 'Doctors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_pharmacy),
            label: 'Pharmacy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.userModel;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${user?.firstName ?? 'Patient'}!',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  DateFormat('EEEE, MMMM d').format(DateTime.now()),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const MessagingScreen()),
              );
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'prescriptions':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const PrescriptionsScreen()),
                  );
                  break;
                case 'bills':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BillingScreen()),
                  );
                  break;
                case 'family':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const FamilyScreen()),
                  );
                  break;
                case 'records':
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MedicalRecordsScreen()),
                  );
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'prescriptions',
                child: ListTile(
                  leading: Icon(Icons.medication),
                  title: Text('Prescriptions'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'bills',
                child: ListTile(
                  leading: Icon(Icons.receipt),
                  title: Text('Bills'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'family',
                child: ListTile(
                  leading: Icon(Icons.family_restroom),
                  title: Text('Family'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'records',
                child: ListTile(
                  leading: Icon(Icons.folder_shared),
                  title: Text('Medical Records'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh data
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Stats
              Text(
                'Quick Overview',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Consumer4<AppointmentProvider, BillingProvider, ConsultationProvider, PharmacyProvider>(
                builder: (context, appointmentProvider, billingProvider, consultationProvider, pharmacyProvider, child) {
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.2,
                    children: [
                      DashboardCard(
                        title: 'Upcoming Appointments',
                        value: appointmentProvider.upcomingAppointments.length.toString(),
                        icon: Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const AppointmentsScreen()),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Cart Items',
                        value: pharmacyProvider.cartItemCount.toString(),
                        icon: Icons.shopping_cart,
                        color: Colors.orange,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PharmacyScreen()),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Recent Consultations',
                        value: consultationProvider.recentConsultations.length.toString(),
                        icon: Icons.medical_services,
                        color: Theme.of(context).colorScheme.secondary,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ConsultationsScreen()),
                          );
                        },
                      ),
                      DashboardCard(
                        title: 'Loyalty Points',
                        value: pharmacyProvider.loyaltyPoints.toString(),
                        icon: Icons.stars,
                        color: Colors.purple,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const PharmacyScreen()),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
              
              // Recent Activity
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              Consumer3<AppointmentProvider, BillingProvider, ConsultationProvider>(
                builder: (context, appointmentProvider, billingProvider, consultationProvider, child) {
                  final recentAppointments = appointmentProvider.appointments.take(2).toList();
                  final recentBills = billingProvider.bills.take(2).toList();
                  final recentConsultations = consultationProvider.recentConsultations.take(2).toList();
                  
                  if (recentAppointments.isEmpty && recentBills.isEmpty && recentConsultations.isEmpty) {
                    return const EmptyState(
                      icon: Icons.history,
                      title: 'No Recent Activity',
                      message: 'Your recent healthcare activities will appear here.',
                    );
                  }
                  
                  return Column(
                    children: [
                      ...recentAppointments.map((appointment) => RecentActivityItem(
                        title: 'Appointment with ${appointment.doctorName}',
                        subtitle: DateFormat('MMM d, y - h:mm a').format(appointment.appointmentDate),
                        icon: Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      )),
                      ...recentBills.map((bill) => RecentActivityItem(
                        title: 'Bill ${bill.billNumber}',
                        subtitle: '\$${bill.totalAmount.toStringAsFixed(2)} - ${bill.statusText}',
                        icon: Icons.receipt,
                        color: bill.isPaid ? Colors.green : Theme.of(context).colorScheme.error,
                      )),
                      ...recentConsultations.map((consultation) => RecentActivityItem(
                        title: 'Consultation with ${consultation.doctorName}',
                        subtitle: DateFormat('MMM d, y').format(consultation.consultationDate),
                        icon: Icons.medical_services,
                        color: Theme.of(context).colorScheme.secondary,
                      )),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
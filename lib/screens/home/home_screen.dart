import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/billing_provider.dart';
import '../../providers/consultation_provider.dart';
import '../../providers/pharmacy_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/medical_background.dart';
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
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Theme
            .of(context)
            .colorScheme
            .primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_search), label: 'Doctors'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_pharmacy), label: 'Pharmacy'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
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
        title: const GreetingHeader(),
        actions: [
          IconButton(
            icon: Image.asset('lib/assets/icons/chat.png', width: 40, height: 40),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const MessagingScreen()));
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              final routes = {
                'prescriptions': const PrescriptionsScreen(),
                'bills': const BillingScreen(),
                'family': const FamilyScreen(),
                'records': const MedicalRecordsScreen(),
              };
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => routes[value]!));
            },
            itemBuilder: (context) =>
            [
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
            icon: Image.asset('lib/assets/icons/settings.png', width: 38, height: 38),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: Stack(
          children: [
          const MedicalBackground(), // 👈 Add your animated medical background
      RefreshIndicator(
        onRefresh: () async {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Dashboard refreshed')),
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🚀 Banner with Carousel
              SizedBox(
                height: 160,
                child: CarouselSlider.builder(
                  unlimitedMode: true,
                  enableAutoSlider: true,
                  autoSliderDelay: const Duration(seconds: 5),
                  itemCount: 3,
                  viewportFraction: 1.0,
                  slideBuilder: (index) {
                    final banners = [
                      'lib/assets/banner1.png',
                      'lib/assets/banner2.png',
                      'lib/assets/banner3.png',
                    ];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          banners[index],
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                        ),
                      ),
                    );
                  },
                  slideTransform: const DefaultTransform(),
                ),
              ),

              const SizedBox(height: 24),
              Text('Quick Overview', style: Theme
                  .of(context)
                  .textTheme
                  .headlineLarge),
              const SizedBox(height: 16),
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return Consumer4<AppointmentProvider,
                      BillingProvider,
                      ConsultationProvider,
                      PharmacyProvider>(
                    builder: (context, appointment, billing, consultation,
                        pharmacy, child) {
                      return Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          SizedBox(
                            width: isWide
                                ? (constraints.maxWidth - 16 * 3) / 4
                                : (constraints.maxWidth - 16) / 2,
                            child: DashboardCard(
                              titleLine1: 'Upcoming',
                              titleLine2: 'Appointments',
                              image: const AssetImage(
                                  'lib/assets/stethoscope.png'),
                              onTap: () =>
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (
                                        _) => const AppointmentsScreen()),
                                  ),
                            ),
                          ),
                          SizedBox(
                            width: isWide
                                ? (constraints.maxWidth - 16 * 3) / 4
                                : (constraints.maxWidth - 16) / 2,
                            child: DashboardCard(
                              titleLine1: 'Cart Items',
                              titleLine2: 'Pharmacy',
                              image: const AssetImage(
                                  'lib/assets/prescription.png'),
                              onTap: () =>
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const PharmacyScreen()),
                                  ),
                            ),
                          ),
                          SizedBox(
                            width: isWide
                                ? (constraints.maxWidth - 16 * 3) / 4
                                : (constraints.maxWidth - 16) / 2,
                            child: DashboardCard(
                              titleLine1: 'Recent',
                              titleLine2: 'Consultations',
                              image: const AssetImage(
                                  'lib/assets/consultation.png'),
                              onTap: () =>
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (
                                        _) => const ConsultationsScreen()),
                                  ),
                            ),
                          ),
                          SizedBox(
                            width: isWide
                                ? (constraints.maxWidth - 16 * 3) / 4
                                : (constraints.maxWidth - 16) / 2,
                            child: DashboardCard(
                              titleLine1: 'Loyalty Points',
                              titleLine2: 'Wellness Packages',
                              image: const AssetImage('lib/assets/stars.png'),
                              onTap: () =>
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const PharmacyScreen()),
                                  ),
                            ),
                          ),
                        ],
                      ).animate().fade(duration: 700.ms).slideY(
                          begin: 0.2, duration: 700.ms);
                    },
                  );
                },
              ),

              const SizedBox(height: 32),
              Text('Recent Activity', style: Theme
                  .of(context)
                  .textTheme
                  .headlineLarge),
              const SizedBox(height: 16),
              Consumer3<AppointmentProvider,
                  BillingProvider,
                  ConsultationProvider>(
                builder: (context, appointment, billing, consultation, child) {
                  final recentAppointments = appointment.appointments
                      .take(2)
                      .toList();
                  final recentBills = billing.bills.take(2).toList();
                  final recentConsults = consultation.recentConsultations.take(
                      2).toList();

                  if (recentAppointments.isEmpty && recentBills.isEmpty &&
                      recentConsults.isEmpty) {
                    return const EmptyState(
                      icon: Icons.history,
                      title: 'No Recent Activity',
                      message: 'Your recent healthcare activities will appear here.',
                    );
                  }

                  return Column(
                    children: [
                      ...recentAppointments.map((a) =>
                          RecentActivityItem(
                            title: 'Appointment with ${a.doctorName}',
                            subtitle: DateFormat('MMM d, y - h:mm a').format(
                                a.appointmentDate),
                            icon: Icons.calendar_today,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .primary,
                          ).animate().fade(duration: 500.ms).slideX(
                              begin: 0.3)),
                      ...recentBills.map((b) =>
                          RecentActivityItem(
                            title: 'Bill ${b.billNumber}',
                            subtitle: '\$${b.totalAmount.toStringAsFixed(
                                2)} - ${b.statusText}',
                            icon: Icons.receipt,
                            color: b.isPaid ? Colors.green : Theme
                                .of(context)
                                .colorScheme
                                .error,
                          ).animate().fade(duration: 500.ms).slideX(
                              begin: 0.3)),
                      ...recentConsults.map((c) =>
                          RecentActivityItem(
                            title: 'Consultation with ${c.doctorName}',
                            subtitle: DateFormat('MMM d, y').format(
                                c.consultationDate),
                            icon: Icons.medical_services,
                            color: Theme
                                .of(context)
                                .colorScheme
                                .secondary,
                          ).animate().fade(duration: 500.ms).slideX(
                              begin: 0.3)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
          ],
      ),
    );
  }
}


  class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context
        .watch<AuthProvider>()
        .userModel;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello, ${user?.firstName ?? 'Patient'}!',
          style: Theme
              .of(context)
              .textTheme
              .headlineLarge,
        ),
        Text(
          DateFormat('EEEE, MMMM d').format(DateTime.now()),
          style: Theme
              .of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(
            color: Theme
                .of(context)
                .colorScheme
                .onSurface
                .withOpacity(0.6),
          ),
        ),
      ],
    );
  }
}

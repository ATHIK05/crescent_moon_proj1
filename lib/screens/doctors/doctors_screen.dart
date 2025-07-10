import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/doctor_provider.dart';
import '../../models/doctor_model.dart';
import '../../widgets/empty_state.dart';
import 'doctor_detail_screen.dart';
import 'doctor_filter_screen.dart';

class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DoctorFilterScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search doctors, specialties, hospitals...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          Provider.of<DoctorProvider>(context, listen: false)
                              .searchDoctors('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) {
                Provider.of<DoctorProvider>(context, listen: false)
                    .searchDoctors(value);
              },
            ),
          ),

          // Quick Filters
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Consumer<DoctorProvider>(
              builder: (context, doctorProvider, child) {
                return ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildQuickFilter(
                      'Video Consultation',
                      doctorProvider.videoConsultationOnly,
                      () => doctorProvider.filterByVideoConsultation(
                        !doctorProvider.videoConsultationOnly,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildQuickFilter(
                      'Highly Rated',
                      doctorProvider.minRating >= 4.0,
                      () => doctorProvider.filterByRating(
                        doctorProvider.minRating >= 4.0 ? 0.0 : 4.0,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (doctorProvider.searchQuery.isNotEmpty ||
                        doctorProvider.selectedSpecialty != null ||
                        doctorProvider.selectedGender != null ||
                        doctorProvider.selectedLanguage != null ||
                        doctorProvider.selectedCity != null ||
                        doctorProvider.videoConsultationOnly ||
                        doctorProvider.minRating > 0.0)
                      TextButton(
                        onPressed: () {
                          doctorProvider.clearFilters();
                          _searchController.clear();
                        },
                        child: const Text('Clear All'),
                      ),
                  ],
                );
              },
            ),
          ),

          // Doctors List
          Expanded(
            child: Consumer<DoctorProvider>(
              builder: (context, doctorProvider, child) {
                if (doctorProvider.filteredDoctors.isEmpty) {
                  return const EmptyState(
                    icon: Icons.person_search,
                    title: 'No Doctors Found',
                    message: 'Try adjusting your search criteria or filters.',
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Refresh doctors list
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: doctorProvider.filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctorProvider.filteredDoctors[index];
                      return _buildDoctorCard(context, doctor);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilter(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
      checkmarkColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorModel doctor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DoctorDetailScreen(doctor: doctor),
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
                  // Doctor Avatar
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      child: doctor.name.isNotEmpty ? Text(
                        doctor.name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                      ) : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Doctor Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Dr. ${doctor.name}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.specializations.join(', '),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${doctor.experience} years experience',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Hospital Info
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doctor.clinics.join(', '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
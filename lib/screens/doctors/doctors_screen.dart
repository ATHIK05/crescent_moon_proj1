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
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    backgroundImage: doctor.profileImage != null
                        ? NetworkImage(doctor.profileImage!)
                        : null,
                    child: doctor.profileImage == null
                        ? Text(
                            doctor.firstName[0] + doctor.lastName[0],
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
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
                                'Dr. ${doctor.fullName}',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            if (doctor.isVerified)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      size: 12,
                                      color: Colors.green,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.specialtyText,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${doctor.experienceYears} years experience',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
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
                    Icons.local_hospital,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      doctor.hospitalName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              if (doctor.city != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      doctor.city!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              
              // Rating and Languages
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.amber,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${doctor.reviewCount})',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Languages: ${doctor.languagesText}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Consultation Options and Fees
              Row(
                children: [
                  if (doctor.isAvailableForInClinic) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.local_hospital,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'In-Clinic',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'AED ${doctor.consultationFee.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  if (doctor.isAvailableForInClinic && doctor.isAvailableForVideo)
                    const SizedBox(width: 8),
                  if (doctor.isAvailableForVideo) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.videocam,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 20,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Video Call',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'AED ${doctor.videoConsultationFee.toStringAsFixed(0)}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
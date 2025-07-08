import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../../models/doctor_model.dart';
import '../../providers/doctor_provider.dart';
import '../../widgets/custom_button.dart';
import '../appointments/book_appointment_screen.dart';

class DoctorDetailScreen extends StatefulWidget {
  final DoctorModel doctor;

  const DoctorDetailScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load doctor reviews
    Provider.of<DoctorProvider>(context, listen: false)
        .loadDoctorReviews(widget.doctor.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dr. ${widget.doctor.fullName}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share doctor profile
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Doctor Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: widget.doctor.profileImage != null
                          ? NetworkImage(widget.doctor.profileImage!)
                          : null,
                      child: widget.doctor.profileImage == null
                          ? Text(
                              widget.doctor.firstName[0] + widget.doctor.lastName[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Dr. ${widget.doctor.fullName}',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                              if (widget.doctor.isVerified)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Verified',
                                        style: TextStyle(
                                          fontSize: 12,
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
                            widget.doctor.specialtyText,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.doctor.experienceYears} years experience',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Rating and Stats
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.doctor.rating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${widget.doctor.reviewCount} reviews',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doctor.hospitalName,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (widget.doctor.city != null)
                            Text(
                              widget.doctor.city!,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab Bar
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'About'),
              Tab(text: 'Reviews'),
              Tab(text: 'Availability'),
            ],
          ),
          
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAboutTab(),
                _buildReviewsTab(),
                _buildAvailabilityTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (widget.doctor.isAvailableForInClinic) ...[
              Expanded(
                child: CustomButton(
                  text: 'Book In-Clinic\nAED ${widget.doctor.consultationFee.toStringAsFixed(0)}',
                  onPressed: () => _bookAppointment(false),
                  isOutlined: true,
                ),
              ),
            ],
            if (widget.doctor.isAvailableForInClinic && widget.doctor.isAvailableForVideo)
              const SizedBox(width: 12),
            if (widget.doctor.isAvailableForVideo) ...[
              Expanded(
                child: CustomButton(
                  text: 'Video Consultation\nAED ${widget.doctor.videoConsultationFee.toStringAsFixed(0)}',
                  onPressed: () => _bookAppointment(true),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.doctor.bio != null) ...[
            Text(
              'About',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              widget.doctor.bio!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
          ],
          
          Text(
            'Qualifications',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          ...widget.doctor.qualifications.map((qualification) => Padding(
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
                    qualification,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
          )),
          const SizedBox(height: 24),
          
          Text(
            'Languages',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.doctor.languages.map((language) => Chip(
              label: Text(language),
              backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            )).toList(),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Consultation Fees',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (widget.doctor.isAvailableForInClinic)
            _buildFeeCard(
              'In-Clinic Consultation',
              widget.doctor.consultationFee,
              Icons.local_hospital,
            ),
          if (widget.doctor.isAvailableForVideo)
            _buildFeeCard(
              'Video Consultation',
              widget.doctor.videoConsultationFee,
              Icons.videocam,
            ),
        ],
      ),
    );
  }

  Widget _buildFeeCard(String title, double fee, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              'AED ${fee.toStringAsFixed(0)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewsTab() {
    return Consumer<DoctorProvider>(
      builder: (context, doctorProvider, child) {
        if (doctorProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (doctorProvider.reviews.isEmpty) {
          return const Center(
            child: Text('No reviews yet'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: doctorProvider.reviews.length,
          itemBuilder: (context, index) {
            final review = doctorProvider.reviews[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            review.patientName[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.patientName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              RatingBarIndicator(
                                rating: review.rating,
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 16.0,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, y').format(review.createdAt),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    if (review.comment != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        review.comment!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAvailabilityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Days',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ...widget.doctor.availableDays.map((day) {
            final timeSlots = widget.doctor.timeSlots[day] ?? [];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.toUpperCase(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (timeSlots.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: timeSlots.map((timeSlot) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            timeSlot,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        )).toList(),
                      )
                    else
                      Text(
                        'No available slots',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _bookAppointment(bool isVideoConsultation) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BookAppointmentScreen(
          doctor: widget.doctor,
          isVideoConsultation: isVideoConsultation,
        ),
      ),
    );
  }
}
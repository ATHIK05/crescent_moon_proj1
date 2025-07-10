import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../models/appointment_model.dart';
import '../../models/doctor_model.dart';
import '../../widgets/custom_button.dart';

class BookAppointmentScreen extends StatefulWidget {
  final DoctorModel? doctor;
  final bool isVideoConsultation;

  const BookAppointmentScreen({
    super.key,
    this.doctor,
    this.isVideoConsultation = false,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();
  
  String? _selectedDoctorId;
  String? _selectedDoctorName;
  String? _selectedDoctorSpecialty;
  String? _selectedTimeSlot;
  AppointmentType _selectedType = AppointmentType.consultation;
  List<String> _availableTimeSlots = [];
  Map<String, bool> slotEnabled = {};
  String? selectedSlotKey;

  void _initializeSlotEnabled(DoctorModel doctor) {
    slotEnabled.clear();
    for (var slot in ['morning', 'evening', 'night']) {
      slotEnabled[slot] = false;
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.doctor != null) {
      _initializeSlotEnabled(widget.doctor!);
      _selectedDoctorId = widget.doctor!.id;
      _selectedDoctorName = widget.doctor!.name;
      _selectedDoctorSpecialty = widget.doctor!.specializations.join(', ');
      _selectedType = widget.isVideoConsultation 
          ? AppointmentType.consultation 
          : AppointmentType.consultation;
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _loadAvailableTimeSlots() {
    // Remove or comment out all code that references DoctorProvider.getAvailableTimeSlots. Only use availableSlots from the doctor model if needed.
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDoctorId == null ||
        _selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final appointmentProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );

    final success = await appointmentProvider.bookAppointment(
      doctorId: _selectedDoctorId!,
      doctorName: _selectedDoctorName!,
      doctorSpecialty: _selectedDoctorSpecialty!,
      appointmentDate: DateTime.now(),
      timeSlot: _selectedTimeSlot!,
      type: _selectedType,
      reason: _reasonController.text.trim().isNotEmpty 
          ? _reasonController.text.trim() 
          : null,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment booked successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(appointmentProvider.errorMessage ?? 'Failed to book appointment'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final slotDefinitions = [
      {
        'key': 'morning',
        'label': 'Morning',
        'icon': Icons.wb_sunny,
        'color': Colors.orange,
        'start': TimeOfDay(hour: 8, minute: 0),
        'end': TimeOfDay(hour: 12, minute: 0),
      },
      {
        'key': 'evening',
        'label': 'Evening',
        'icon': Icons.wb_twilight,
        'color': Colors.deepPurple,
        'start': TimeOfDay(hour: 14, minute: 0),
        'end': TimeOfDay(hour: 18, minute: 0),
      },
      {
        'key': 'night',
        'label': 'Night',
        'icon': Icons.nightlight_round,
        'color': Colors.indigo,
        'start': TimeOfDay(hour: 18, minute: 0),
        'end': TimeOfDay(hour: 22, minute: 0),
      },
    ];
    List<String> getTimeChips(TimeOfDay start, TimeOfDay end) {
      final chips = <String>[];
      var current = start;
      while (current.hour < end.hour || (current.hour == end.hour && current.minute < end.minute)) {
        int nextMinute = current.minute + 15;
        int nextHour = current.hour;
        if (nextMinute >= 60) {
          nextHour += nextMinute ~/ 60;
          nextMinute = nextMinute % 60;
        }
        final next = TimeOfDay(hour: nextHour, minute: nextMinute);
        final label = '${current.format(context)} - ${next.format(context)}';
        chips.add(label);
        if (next.hour > end.hour || (next.hour == end.hour && next.minute > end.minute)) break;
        current = next;
      }
      return chips;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isVideoConsultation 
            ? 'Book Video Consultation' 
            : 'Book Appointment'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.doctor == null) ...[
                Text(
                'Select Doctor',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedDoctorId,
                decoration: const InputDecoration(
                  labelText: 'Doctor',
                  prefixIcon: Icon(Icons.person),
                ),
                items: Provider.of<DoctorProvider>(context)
                    .doctors
                    .map((doctor) {
                  return DropdownMenuItem(
                    value: doctor.id,
                    child: Text(
                      'Dr. ${doctor.name} (${doctor.specializations.join(', ')})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDoctorId = value;
                    final doctor = Provider.of<DoctorProvider>(context, listen: false)
                        .doctors
                        .firstWhere((d) => d.id == value);
                    _selectedDoctorName = doctor.name;
                    _selectedDoctorSpecialty = doctor.specializations.join(', ');
                    _selectedTimeSlot = null;
                    _availableTimeSlots = [];
                    _initializeSlotEnabled(doctor);
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a doctor';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ] else ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            widget.doctor!.name[0],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Dr. ${widget.doctor!.name}',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                widget.doctor!.specializations.join(', '),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.isVideoConsultation 
                                ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                                : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                widget.isVideoConsultation ? Icons.videocam : Icons.local_hospital,
                                size: 16,
                                color: widget.isVideoConsultation 
                                    ? Theme.of(context).colorScheme.secondary
                                    : Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.isVideoConsultation ? 'Video' : 'In-Clinic',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: widget.isVideoConsultation 
                                      ? Theme.of(context).colorScheme.secondary
                                      : Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              
              Text(
                'Appointment Type',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<AppointmentType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type',
                  prefixIcon: Icon(Icons.medical_services),
                ),
                items: AppointmentType.values.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(_getTypeText(type)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),
              Text(
                'Select Time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Builder(
                builder: (context) {
                  DoctorModel? doctor;
                  if (widget.doctor != null) {
                    doctor = widget.doctor;
                  } else if (_selectedDoctorId != null) {
                    final doctors = Provider.of<DoctorProvider>(context, listen: false).doctors;
                    final found = doctors.where((d) => d.id == _selectedDoctorId);
                    doctor = found.isNotEmpty ? found.first : null;
                  }
                  if (doctor == null) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text(
                          'Please select a doctor to view available time slots.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }
                  final DoctorModel d = doctor;

                  final now = DateTime.now();
                  final today = DateTime(now.year, now.month, now.day);

                  return FutureBuilder<QuerySnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('appointments')
                        .where('doctorId', isEqualTo: d.id)
                        .where('appointmentDate',
                            isGreaterThanOrEqualTo: DateTime(today.year, today.month, today.day),
                            isLessThan: DateTime(today.year, today.month, today.day + 1))
                        .get(),
                    builder: (context, snapshot) {
                      final bookedSlots = <String>{};
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (data['timeSlot'] != null) {
                            bookedSlots.add(data['timeSlot']);
                          }
                        }
                      }

                      List<String> getAvailableTimeChips(TimeOfDay start, TimeOfDay end) {
                        final chips = <String>[];
                        var current = start;
                        while (current.hour < end.hour ||
                            (current.hour == end.hour && current.minute < end.minute)) {
                          int nextMinute = current.minute + 15;
                          int nextHour = current.hour;
                          if (nextMinute >= 60) {
                            nextHour += nextMinute ~/ 60;
                            nextMinute = nextMinute % 60;
                          }
                          final next = TimeOfDay(hour: nextHour, minute: nextMinute);
                          final label = '${current.format(context)} - ${next.format(context)}';

                          bool isPast = false;
                          if (today == DateTime(now.year, now.month, now.day)) {
                            final slotEnd = DateTime(
                              now.year,
                              now.month,
                              now.day,
                              next.hour,
                              next.minute,
                            );
                            if (slotEnd.isBefore(now)) isPast = true;
                          }
                          if (!bookedSlots.contains(label) && !isPast) {
                            chips.add(label);
                          }
                          if (next.hour > end.hour ||
                              (next.hour == end.hour && next.minute > end.minute)) break;
                          current = next;
                        }
                        return chips;
                      }

                      final slotChips = slotDefinitions
                          .where((slot) => d.availableSlots.contains(slot['key']))
                          .map((slot) {
                        final key = slot['key'] as String;
                        final availableChips = getAvailableTimeChips(
                            slot['start'] as TimeOfDay, slot['end'] as TimeOfDay);
                        return availableChips.isNotEmpty;
                      }).toList();

                      // If no slots at all are available, show a friendly message
                      final noSlotsAvailable = slotChips.isEmpty || slotChips.every((v) => v == false);

                      if (noSlotsAvailable) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No available time slots for booking.\nPlease select another date or doctor.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: slotDefinitions
                            .where((slot) => d.availableSlots.contains(slot['key']))
                            .map((slot) {
                          final key = slot['key'] as String;
                          final availableChips = getAvailableTimeChips(
                              slot['start'] as TimeOfDay, slot['end'] as TimeOfDay);
                          if (availableChips.isEmpty) return const SizedBox.shrink();
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 3,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(slot['icon'] as IconData, color: slot['color'] as Color, size: 28),
                                      const SizedBox(width: 12),
                                      Text(
                                        slot['label'] as String,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${(slot['start'] as TimeOfDay).format(context)} - ${(slot['end'] as TimeOfDay).format(context)}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                                      ),
                                      const Spacer(),
                                      Switch(
                                        value: slotEnabled[key] ?? false,
                                        onChanged: (val) {
                                          setState(() {
                                            slotEnabled[key] = val;
                                            if (val) selectedSlotKey = key;
                                            else if (selectedSlotKey == key) selectedSlotKey = null;
                                            _selectedTimeSlot = null;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                  if (slotEnabled[key] ?? false) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children: availableChips.map((chip) {
                                        final isSelected = _selectedTimeSlot == chip;
                                        return ChoiceChip(
                                          label: Text(chip),
                                          selected: isSelected,
                                          onSelected: (selected) {
                                            setState(() {
                                              _selectedTimeSlot = selected ? chip : null;
                                            });
                                          },
                                          selectedColor: Theme.of(context).colorScheme.primary,
                                          labelStyle: TextStyle(
                                            color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
              
              Text(
                'Reason (Optional)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _reasonController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Describe your symptoms or reason for visit',
                  prefixIcon: Icon(Icons.note),
                ),
              ),
              const SizedBox(height: 32),
              
              Text(
                'Additional Notes (Optional)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Any additional information for the doctor',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
              const SizedBox(height: 32),
              
              Consumer<AppointmentProvider>(
                builder: (context, appointmentProvider, child) {
                  return CustomButton(
                    text: widget.isVideoConsultation 
                        ? 'Book Video Consultation' 
                        : 'Book Appointment',
                    onPressed: _bookAppointment,
                    isLoading: appointmentProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTypeText(AppointmentType type) {
    switch (type) {
      case AppointmentType.consultation:
        return 'Consultation';
      case AppointmentType.followUp:
        return 'Follow-up';
      case AppointmentType.checkup:
        return 'Check-up';
      case AppointmentType.emergency:
        return 'Emergency';
    }
  }
}
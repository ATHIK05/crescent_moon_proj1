import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
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
  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  AppointmentType _selectedType = AppointmentType.consultation;
  List<String> _availableTimeSlots = [];
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    if (widget.doctor != null) {
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

  void _onDateSelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDate, selectedDay)) {
      setState(() {
        _selectedDate = selectedDay;
        _focusedDay = focusedDay;
        _selectedTimeSlot = null;
        _loadAvailableTimeSlots();
      });
    }
  }

  void _loadAvailableTimeSlots() {
    // Remove or comment out all code that references DoctorProvider.getAvailableTimeSlots. Only use availableSlots from the doctor model if needed.
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDoctorId == null ||
        _selectedDate == null ||
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
      appointmentDate: _selectedDate!,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Dr. ${doctor.name}'),
                        Text(
                          doctor.specializations.join(', '),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
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
                    _selectedDate = null;
                    _selectedTimeSlot = null;
                    _availableTimeSlots = [];
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
                'Select Date',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: TableCalendar<dynamic>(
                    firstDay: DateTime.now(),
                    lastDay: DateTime.now().add(const Duration(days: 90)),
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDate, day);
                    },
                    onDaySelected: _onDateSelected,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    enabledDayPredicate: (day) {
                      // Only enable days that are not in the past
                      return !day.isBefore(DateTime.now().subtract(const Duration(days: 1)));
                    },
                    calendarStyle: CalendarStyle(
                      outsideDaysVisible: false,
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Select Time',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              if (_availableTimeSlots.isEmpty && _selectedDate != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No available time slots for the selected date. Please choose another date.',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_availableTimeSlots.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTimeSlots.map((timeSlot) {
                    final isSelected = _selectedTimeSlot == timeSlot;
                    return FilterChip(
                      label: Text(timeSlot),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedTimeSlot = selected ? timeSlot : null;
                        });
                      },
                    );
                  }).toList(),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Please select a date to view available time slots',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
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
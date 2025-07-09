import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/doctor_provider.dart';
import '../../models/doctor_model.dart';
import '../../widgets/custom_button.dart';

class DoctorFilterScreen extends StatefulWidget {
  const DoctorFilterScreen({super.key});

  @override
  State<DoctorFilterScreen> createState() => _DoctorFilterScreenState();
}

class _DoctorFilterScreenState extends State<DoctorFilterScreen> {
  late DoctorProvider _doctorProvider;
  
  DoctorSpecialty? _selectedSpecialty;
  DoctorGender? _selectedGender;
  String? _selectedLanguage;
  String? _selectedCity;
  bool _videoConsultationOnly = false;
  double _minRating = 0.0;

  @override
  void initState() {
    super.initState();
    _doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    
    // Initialize with current filter values
    _selectedSpecialty = _doctorProvider.selectedSpecialty;
    _selectedGender = _doctorProvider.selectedGender;
    _selectedLanguage = _doctorProvider.selectedLanguage;
    _selectedCity = _doctorProvider.selectedCity;
    _videoConsultationOnly = _doctorProvider.videoConsultationOnly;
    _minRating = _doctorProvider.minRating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Doctors'),
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Specialty Filter
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Specialty',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<DoctorSpecialty>(
                      value: _selectedSpecialty,
                      decoration: const InputDecoration(
                        labelText: 'Select Specialty',
                        prefixIcon: Icon(Icons.medical_services),
                      ),
                      items: DoctorSpecialty.values.map((specialty) {
                        return DropdownMenuItem(
                          value: specialty,
                          child: Text(_getSpecialtyText(specialty)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSpecialty = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Gender Filter
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<DoctorGender>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Select Gender',
                        prefixIcon: Icon(Icons.person),
                      ),
                      items: DoctorGender.values.map((gender) {
                        return DropdownMenuItem(
                          value: gender,
                          child: Text(_getGenderText(gender)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Language Filter
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Language',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Select Language',
                        prefixIcon: Icon(Icons.language),
                      ),
                      items: _doctorProvider.getAllLanguages().map((language) {
                        return DropdownMenuItem(
                          value: language,
                          child: Text(language),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedLanguage = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // City Filter
            // Text(
            //   'City',
            //   style: Theme.of(context).textTheme.titleLarge,
            // ),
            // const SizedBox(height: 8),
            // DropdownButtonFormField<String>(
            //   value: _selectedCity,
            //   decoration: const InputDecoration(
            //     labelText: 'Select City',
            //     prefixIcon: Icon(Icons.location_city),
            //   ),
            //   items: _doctorProvider.getAllCities().map((city) {
            //     return DropdownMenuItem(
            //       value: city,
            //       child: Text(city),
            //     );
            //   }).toList(),
            //   onChanged: (value) {
            //     setState(() {
            //       _selectedCity = value;
            //     });
            //   },
            // ),
            // const SizedBox(height: 24),

            // Video Consultation Filter
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Video Consultation Available'),
                      subtitle: const Text('Show only doctors available for video calls'),
                      value: _videoConsultationOnly,
                      onChanged: (value) {
                        setState(() {
                          _videoConsultationOnly = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Rating Filter
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Minimum Rating',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _minRating,
                            min: 0.0,
                            max: 5.0,
                            divisions: 10,
                            label: _minRating == 0.0 ? 'Any' : _minRating.toStringAsFixed(1),
                            onChanged: (value) {
                              setState(() {
                                _minRating = value;
                              });
                            },
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _minRating == 0.0 ? 'Any' : _minRating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: CustomButton(
                text: 'Clear Filters',
                onPressed: _clearAllFilters,
                isOutlined: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomButton(
                text: 'Apply Filters',
                onPressed: _applyFilters,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSpecialtyText(DoctorSpecialty specialty) {
    switch (specialty) {
      case DoctorSpecialty.generalMedicine:
        return 'General Medicine';
      case DoctorSpecialty.cardiology:
        return 'Cardiology';
      case DoctorSpecialty.dermatology:
        return 'Dermatology';
      case DoctorSpecialty.orthopedics:
        return 'Orthopedics';
      case DoctorSpecialty.pediatrics:
        return 'Pediatrics';
      case DoctorSpecialty.gynecology:
        return 'Gynecology';
      case DoctorSpecialty.neurology:
        return 'Neurology';
      case DoctorSpecialty.psychiatry:
        return 'Psychiatry';
      case DoctorSpecialty.ophthalmology:
        return 'Ophthalmology';
      case DoctorSpecialty.ent:
        return 'ENT';
      case DoctorSpecialty.urology:
        return 'Urology';
      case DoctorSpecialty.oncology:
        return 'Oncology';
      case DoctorSpecialty.endocrinology:
        return 'Endocrinology';
      case DoctorSpecialty.gastroenterology:
        return 'Gastroenterology';
      case DoctorSpecialty.pulmonology:
        return 'Pulmonology';
      case DoctorSpecialty.nephrology:
        return 'Nephrology';
      case DoctorSpecialty.rheumatology:
        return 'Rheumatology';
      case DoctorSpecialty.anesthesiology:
        return 'Anesthesiology';
      case DoctorSpecialty.radiology:
        return 'Radiology';
      case DoctorSpecialty.pathology:
        return 'Pathology';
    }
  }

  String _getGenderText(DoctorGender gender) {
    switch (gender) {
      case DoctorGender.male:
        return 'Male';
      case DoctorGender.female:
        return 'Female';
      case DoctorGender.other:
        return 'Other';
    }
  }

  void _clearAllFilters() {
    setState(() {
      _selectedSpecialty = null;
      _selectedGender = null;
      _selectedLanguage = null;
      _selectedCity = null;
      _videoConsultationOnly = false;
      _minRating = 0.0;
    });
  }

  void _applyFilters() {
    _doctorProvider.filterBySpecialty(_selectedSpecialty);
    _doctorProvider.filterByGender(_selectedGender);
    _doctorProvider.filterByLanguage(_selectedLanguage);
    _doctorProvider.filterByCity(_selectedCity);
    _doctorProvider.filterByVideoConsultation(_videoConsultationOnly);
    _doctorProvider.filterByRating(_minRating);
    
    Navigator.of(context).pop();
  }
}
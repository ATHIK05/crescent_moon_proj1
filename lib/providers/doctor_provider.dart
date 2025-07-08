import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/doctor_model.dart';

class DoctorProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<DoctorModel> _doctors = [];
  List<DoctorModel> _filteredDoctors = [];
  List<DoctorReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Filter properties
  String _searchQuery = '';
  DoctorSpecialty? _selectedSpecialty;
  DoctorGender? _selectedGender;
  String? _selectedLanguage;
  String? _selectedCity;
  bool _videoConsultationOnly = false;
  double _minRating = 0.0;

  List<DoctorModel> get doctors => _doctors;
  List<DoctorModel> get filteredDoctors => _filteredDoctors;
  List<DoctorReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  String get searchQuery => _searchQuery;
  DoctorSpecialty? get selectedSpecialty => _selectedSpecialty;
  DoctorGender? get selectedGender => _selectedGender;
  String? get selectedLanguage => _selectedLanguage;
  String? get selectedCity => _selectedCity;
  bool get videoConsultationOnly => _videoConsultationOnly;
  double get minRating => _minRating;

  DoctorProvider() {
    _loadDoctors();
  }

  void _loadDoctors() {
    _firestore
        .collection('doctors')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _doctors = snapshot.docs
          .map((doc) => DoctorModel.fromFirestore(doc))
          .toList();
      _applyFilters();
      notifyListeners();
    });
  }

  void searchDoctors(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterBySpecialty(DoctorSpecialty? specialty) {
    _selectedSpecialty = specialty;
    _applyFilters();
    notifyListeners();
  }

  void filterByGender(DoctorGender? gender) {
    _selectedGender = gender;
    _applyFilters();
    notifyListeners();
  }

  void filterByLanguage(String? language) {
    _selectedLanguage = language;
    _applyFilters();
    notifyListeners();
  }

  void filterByCity(String? city) {
    _selectedCity = city;
    _applyFilters();
    notifyListeners();
  }

  void filterByVideoConsultation(bool videoOnly) {
    _videoConsultationOnly = videoOnly;
    _applyFilters();
    notifyListeners();
  }

  void filterByRating(double rating) {
    _minRating = rating;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedSpecialty = null;
    _selectedGender = null;
    _selectedLanguage = null;
    _selectedCity = null;
    _videoConsultationOnly = false;
    _minRating = 0.0;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredDoctors = _doctors.where((doctor) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!doctor.fullName.toLowerCase().contains(query) &&
            !doctor.specialtyText.toLowerCase().contains(query) &&
            !doctor.hospitalName.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Specialty filter
      if (_selectedSpecialty != null && doctor.specialty != _selectedSpecialty) {
        return false;
      }

      // Gender filter
      if (_selectedGender != null && doctor.gender != _selectedGender) {
        return false;
      }

      // Language filter
      if (_selectedLanguage != null && 
          !doctor.languages.contains(_selectedLanguage)) {
        return false;
      }

      // City filter
      if (_selectedCity != null && doctor.city != _selectedCity) {
        return false;
      }

      // Video consultation filter
      if (_videoConsultationOnly && !doctor.isAvailableForVideo) {
        return false;
      }

      // Rating filter
      if (doctor.rating < _minRating) {
        return false;
      }

      return true;
    }).toList();

    // Sort by rating and review count
    _filteredDoctors.sort((a, b) {
      final ratingComparison = b.rating.compareTo(a.rating);
      if (ratingComparison != 0) return ratingComparison;
      return b.reviewCount.compareTo(a.reviewCount);
    });
  }

  Future<void> loadDoctorReviews(String doctorId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final snapshot = await _firestore
          .collection('doctor_reviews')
          .where('doctorId', isEqualTo: doctorId)
          .orderBy('createdAt', descending: true)
          .get();

      _reviews = snapshot.docs
          .map((doc) => DoctorReviewModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      _errorMessage = 'Failed to load reviews: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> getAvailableTimeSlots(String doctorId, DateTime date) {
    final doctor = _doctors.firstWhere((d) => d.id == doctorId);
    final dayName = _getDayName(date.weekday);
    
    if (!doctor.availableDays.contains(dayName)) {
      return [];
    }

    return doctor.timeSlots[dayName] ?? [];
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'monday';
      case 2: return 'tuesday';
      case 3: return 'wednesday';
      case 4: return 'thursday';
      case 5: return 'friday';
      case 6: return 'saturday';
      case 7: return 'sunday';
      default: return 'monday';
    }
  }

  List<String> getAllSpecialties() {
    return _doctors
        .map((doctor) => doctor.specialtyText)
        .toSet()
        .toList()
        ..sort();
  }

  List<String> getAllLanguages() {
    final languages = <String>{};
    for (final doctor in _doctors) {
      languages.addAll(doctor.languages);
    }
    return languages.toList()..sort();
  }

  List<String> getAllCities() {
    return _doctors
        .where((doctor) => doctor.city != null)
        .map((doctor) => doctor.city!)
        .toSet()
        .toList()
        ..sort();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
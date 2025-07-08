import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/appointment_model.dart';

class AppointmentProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<AppointmentModel> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<AppointmentModel> get appointments => _appointments;
  List<AppointmentModel> get upcomingAppointments => 
      _appointments.where((apt) => apt.isUpcoming).toList();
  List<AppointmentModel> get pastAppointments => 
      _appointments.where((apt) => apt.isPast).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AppointmentProvider() {
    _loadAppointments();
  }

  void _loadAppointments() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('appointments')
        .where('patientId', isEqualTo: user.uid)
        .orderBy('appointmentDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _appointments = snapshot.docs
          .map((doc) => AppointmentModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  Future<bool> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    required DateTime appointmentDate,
    required String timeSlot,
    required AppointmentType type,
    String? reason,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final appointment = AppointmentModel(
        id: '',
        patientId: user.uid,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
        appointmentDate: appointmentDate,
        timeSlot: timeSlot,
        type: type,
        status: AppointmentStatus.scheduled,
        reason: reason,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('appointments')
          .add(appointment.toFirestore());

      return true;
    } catch (e) {
      _errorMessage = 'Failed to book appointment: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'status': AppointmentStatus.cancelled.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel appointment: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rescheduleAppointment({
    required String appointmentId,
    required DateTime newDate,
    required String newTimeSlot,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestore
          .collection('appointments')
          .doc(appointmentId)
          .update({
        'appointmentDate': Timestamp.fromDate(newDate),
        'timeSlot': newTimeSlot,
        'status': AppointmentStatus.rescheduled.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to reschedule appointment: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
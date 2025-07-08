import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/prescription_model.dart';

class PrescriptionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<PrescriptionModel> _prescriptions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PrescriptionModel> get prescriptions => _prescriptions;
  List<PrescriptionModel> get activePrescriptions => 
      _prescriptions.where((p) => p.status == PrescriptionStatus.active).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  PrescriptionProvider() {
    _loadPrescriptions();
  }

  void _loadPrescriptions() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('prescriptions')
        .where('patientId', isEqualTo: user.uid)
        .orderBy('prescribedDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _prescriptions = snapshot.docs
          .map((doc) => PrescriptionModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  Future<bool> requestRenewal(String prescriptionId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestore
          .collection('prescriptions')
          .doc(prescriptionId)
          .update({
        'status': PrescriptionStatus.renewalRequested.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to request renewal: $e';
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
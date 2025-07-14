import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/consultation_model.dart';

class ConsultationProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ConsultationModel> _consultations = [];
  final bool _isLoading = false;
  String? _errorMessage;

  List<ConsultationModel> get consultations => _consultations;
  List<ConsultationModel> get recentConsultations => 
      _consultations.take(5).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  ConsultationProvider() {
    _loadConsultations();
  }

  void _loadConsultations() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('consultations')
        .where('patientId', isEqualTo: user.uid)
        .orderBy('consultationDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _consultations = snapshot.docs
          .map((doc) => ConsultationModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
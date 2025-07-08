import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/medical_record_model.dart';

class MedicalRecordsProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<MedicalRecordModel> _records = [];
  List<HealthPackageModel> _healthPackages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<MedicalRecordModel> get records => _records;
  List<HealthPackageModel> get healthPackages => _healthPackages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MedicalRecordsProvider() {
    _loadMedicalRecords();
    _loadHealthPackages();
  }

  void _loadMedicalRecords() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('medical_records')
        .where('patientId', isEqualTo: user.uid)
        .orderBy('recordDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _records = snapshot.docs
          .map((doc) => MedicalRecordModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  void _loadHealthPackages() {
    _firestore
        .collection('health_packages')
        .orderBy('isPopular', descending: true)
        .snapshots()
        .listen((snapshot) {
      _healthPackages = snapshot.docs
          .map((doc) => HealthPackageModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  Future<bool> addMedicalRecord(MedicalRecordModel record) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final recordWithPatientId = MedicalRecordModel(
        id: record.id,
        patientId: user.uid,
        familyMemberId: record.familyMemberId,
        type: record.type,
        title: record.title,
        description: record.description,
        doctorName: record.doctorName,
        hospitalName: record.hospitalName,
        recordDate: record.recordDate,
        pdfBase64: record.pdfBase64,
        imageBase64: record.imageBase64,
        labValues: record.labValues,
        tags: record.tags,
        isShared: record.isShared,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('medical_records')
          .add(recordWithPatientId.toFirestore());

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add medical record: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMedicalRecord(MedicalRecordModel record) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedRecord = MedicalRecordModel(
        id: record.id,
        patientId: record.patientId,
        familyMemberId: record.familyMemberId,
        type: record.type,
        title: record.title,
        description: record.description,
        doctorName: record.doctorName,
        hospitalName: record.hospitalName,
        recordDate: record.recordDate,
        pdfBase64: record.pdfBase64,
        imageBase64: record.imageBase64,
        labValues: record.labValues,
        tags: record.tags,
        isShared: record.isShared,
        createdAt: record.createdAt,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('medical_records')
          .doc(record.id)
          .update(updatedRecord.toFirestore());

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update medical record: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteMedicalRecord(String recordId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestore.collection('medical_records').doc(recordId).delete();

      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete medical record: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<MedicalRecordModel> getRecordsByType(RecordType type) {
    return _records.where((record) => record.type == type).toList();
  }

  List<MedicalRecordModel> getRecordsByFamilyMember(String? familyMemberId) {
    return _records
        .where((record) => record.familyMemberId == familyMemberId)
        .toList();
  }

  List<MedicalRecordModel> searchRecords(String query) {
    final lowerQuery = query.toLowerCase();
    return _records.where((record) {
      return record.title.toLowerCase().contains(lowerQuery) ||
          record.description.toLowerCase().contains(lowerQuery) ||
          (record.doctorName?.toLowerCase().contains(lowerQuery) ?? false) ||
          (record.hospitalName?.toLowerCase().contains(lowerQuery) ?? false) ||
          record.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  Map<String, List<MedicalRecordModel>> getRecordsGroupedByDate() {
    final grouped = <String, List<MedicalRecordModel>>{};
    
    for (final record in _records) {
      final dateKey = '${record.recordDate.year}-${record.recordDate.month.toString().padLeft(2, '0')}';
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(record);
    }
    
    return grouped;
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
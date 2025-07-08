import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/family_model.dart';

class FamilyProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<FamilyMemberModel> _familyMembers = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<FamilyMemberModel> get familyMembers => _familyMembers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  FamilyProvider() {
    _loadFamilyMembers();
  }

  void _loadFamilyMembers() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('family_members')
        .where('primaryUserId', isEqualTo: user.uid)
        .where('isActive', isEqualTo: true)
        .orderBy('relationship')
        .snapshots()
        .listen((snapshot) {
      _familyMembers = snapshot.docs
          .map((doc) => FamilyMemberModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  Future<bool> addFamilyMember(FamilyMemberModel member) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final memberWithUserId = FamilyMemberModel(
        id: member.id,
        primaryUserId: user.uid,
        firstName: member.firstName,
        lastName: member.lastName,
        email: member.email,
        phoneNumber: member.phoneNumber,
        dateOfBirth: member.dateOfBirth,
        gender: member.gender,
        relationship: member.relationship,
        bloodGroup: member.bloodGroup,
        height: member.height,
        weight: member.weight,
        allergies: member.allergies,
        chronicConditions: member.chronicConditions,
        medications: member.medications,
        emergencyContact: member.emergencyContact,
        emergencyContactPhone: member.emergencyContactPhone,
        insuranceProvider: member.insuranceProvider,
        insuranceNumber: member.insuranceNumber,
        profileImage: member.profileImage,
        isActive: true,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('family_members')
          .add(memberWithUserId.toFirestore());

      return true;
    } catch (e) {
      _errorMessage = 'Failed to add family member: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateFamilyMember(FamilyMemberModel member) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedMember = FamilyMemberModel(
        id: member.id,
        primaryUserId: member.primaryUserId,
        firstName: member.firstName,
        lastName: member.lastName,
        email: member.email,
        phoneNumber: member.phoneNumber,
        dateOfBirth: member.dateOfBirth,
        gender: member.gender,
        relationship: member.relationship,
        bloodGroup: member.bloodGroup,
        height: member.height,
        weight: member.weight,
        allergies: member.allergies,
        chronicConditions: member.chronicConditions,
        medications: member.medications,
        emergencyContact: member.emergencyContact,
        emergencyContactPhone: member.emergencyContactPhone,
        insuranceProvider: member.insuranceProvider,
        insuranceNumber: member.insuranceNumber,
        profileImage: member.profileImage,
        isActive: member.isActive,
        createdAt: member.createdAt,
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('family_members')
          .doc(member.id)
          .update(updatedMember.toFirestore());

      return true;
    } catch (e) {
      _errorMessage = 'Failed to update family member: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> removeFamilyMember(String memberId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestore
          .collection('family_members')
          .doc(memberId)
          .update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to remove family member: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  FamilyMemberModel? getFamilyMember(String memberId) {
    try {
      return _familyMembers.firstWhere((member) => member.id == memberId);
    } catch (e) {
      return null;
    }
  }

  List<FamilyMemberModel> getFamilyMembersByRelationship(Relationship relationship) {
    return _familyMembers
        .where((member) => member.relationship == relationship)
        .toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
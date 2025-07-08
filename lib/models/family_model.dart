import 'package:cloud_firestore/cloud_firestore.dart';

enum Relationship {
  self,
  spouse,
  child,
  parent,
  sibling,
  grandparent,
  grandchild,
  other,
}

enum BloodGroup {
  aPositive,
  aNegative,
  bPositive,
  bNegative,
  abPositive,
  abNegative,
  oPositive,
  oNegative,
}

class FamilyMemberModel {
  final String id;
  final String primaryUserId;
  final String firstName;
  final String lastName;
  final String? email;
  final String? phoneNumber;
  final DateTime dateOfBirth;
  final String gender;
  final Relationship relationship;
  final BloodGroup? bloodGroup;
  final double? height;
  final double? weight;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<String> medications;
  final String? emergencyContact;
  final String? emergencyContactPhone;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final String? profileImage;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  FamilyMemberModel({
    required this.id,
    required this.primaryUserId,
    required this.firstName,
    required this.lastName,
    this.email,
    this.phoneNumber,
    required this.dateOfBirth,
    required this.gender,
    required this.relationship,
    this.bloodGroup,
    this.height,
    this.weight,
    required this.allergies,
    required this.chronicConditions,
    required this.medications,
    this.emergencyContact,
    this.emergencyContactPhone,
    this.insuranceProvider,
    this.insuranceNumber,
    this.profileImage,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month || 
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  String get relationshipText {
    switch (relationship) {
      case Relationship.self:
        return 'Self';
      case Relationship.spouse:
        return 'Spouse';
      case Relationship.child:
        return 'Child';
      case Relationship.parent:
        return 'Parent';
      case Relationship.sibling:
        return 'Sibling';
      case Relationship.grandparent:
        return 'Grandparent';
      case Relationship.grandchild:
        return 'Grandchild';
      case Relationship.other:
        return 'Other';
    }
  }

  String? get bloodGroupText {
    if (bloodGroup == null) return null;
    switch (bloodGroup!) {
      case BloodGroup.aPositive:
        return 'A+';
      case BloodGroup.aNegative:
        return 'A-';
      case BloodGroup.bPositive:
        return 'B+';
      case BloodGroup.bNegative:
        return 'B-';
      case BloodGroup.abPositive:
        return 'AB+';
      case BloodGroup.abNegative:
        return 'AB-';
      case BloodGroup.oPositive:
        return 'O+';
      case BloodGroup.oNegative:
        return 'O-';
    }
  }

  double? get bmi {
    if (height == null || weight == null) return null;
    final heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }

  factory FamilyMemberModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FamilyMemberModel(
      id: doc.id,
      primaryUserId: data['primaryUserId'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'],
      phoneNumber: data['phoneNumber'],
      dateOfBirth: (data['dateOfBirth'] as Timestamp).toDate(),
      gender: data['gender'] ?? '',
      relationship: Relationship.values.firstWhere(
        (e) => e.toString().split('.').last == data['relationship'],
        orElse: () => Relationship.other,
      ),
      bloodGroup: data['bloodGroup'] != null
          ? BloodGroup.values.firstWhere(
              (e) => e.toString().split('.').last == data['bloodGroup'],
              orElse: () => BloodGroup.oPositive,
            )
          : null,
      height: data['height']?.toDouble(),
      weight: data['weight']?.toDouble(),
      allergies: List<String>.from(data['allergies'] ?? []),
      chronicConditions: List<String>.from(data['chronicConditions'] ?? []),
      medications: List<String>.from(data['medications'] ?? []),
      emergencyContact: data['emergencyContact'],
      emergencyContactPhone: data['emergencyContactPhone'],
      insuranceProvider: data['insuranceProvider'],
      insuranceNumber: data['insuranceNumber'],
      profileImage: data['profileImage'],
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'primaryUserId': primaryUserId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'gender': gender,
      'relationship': relationship.toString().split('.').last,
      'bloodGroup': bloodGroup?.toString().split('.').last,
      'height': height,
      'weight': weight,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'medications': medications,
      'emergencyContact': emergencyContact,
      'emergencyContactPhone': emergencyContactPhone,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'profileImage': profileImage,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
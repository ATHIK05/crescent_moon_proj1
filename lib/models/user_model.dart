import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final String? address;
  final String? emergencyContact;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.address,
    this.emergencyContact,
    this.insuranceProvider,
    this.insuranceNumber,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      emergencyContact: data['emergencyContact'],
      insuranceProvider: data['insuranceProvider'],
      insuranceNumber: data['insuranceNumber'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'phoneNumber': phoneNumber,
      'address': address,
      'emergencyContact': emergencyContact,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  UserModel copyWith({
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? address,
    String? emergencyContact,
    String? insuranceProvider,
    String? insuranceNumber,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
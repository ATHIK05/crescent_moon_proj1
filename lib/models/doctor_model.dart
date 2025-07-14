import 'package:cloud_firestore/cloud_firestore.dart';

enum DoctorSpecialty {
  generalMedicine,
  cardiology,
  dermatology,
  orthopedics,
  pediatrics,
  gynecology,
  neurology,
  psychiatry,
  ophthalmology,
  ent,
  urology,
  oncology,
  endocrinology,
  gastroenterology,
  pulmonology,
  nephrology,
  rheumatology,
  anesthesiology,
  radiology,
  pathology,
}

enum DoctorGender { male, female, other }

class DoctorModel {
  final String id;
  final String name;
  final String? phone;
  final List<String> specializations;
  final List<String> education;
  final int experience;
  final List<String> languages;
  final List<String> clinics;
  final List<String> availableSlots;
  final bool isCheckedIn;
  final List<String> services;
  final DateTime? checkedInAt;
  final DateTime? checkedOutAt;
  final DateTime? lastUpdated;
  final String introduction;

  DoctorModel({
    required this.id,
    required this.name,
    this.phone,
    required this.specializations,
    required this.education,
    required this.experience,
    required this.languages,
    required this.clinics,
    required this.availableSlots,
    required this.isCheckedIn,
    required this.services,
    required this.introduction,
    this.checkedInAt,
    this.checkedOutAt,
    this.lastUpdated,
  });
  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'],
      specializations: List<String>.from(data['specializations'] ?? []),
      education: List<String>.from(data['education'] ?? []),
      experience: (data['experience'] ?? 0) is int
          ? data['experience']
          : int.tryParse(data['experience'].toString()) ?? 0,
      languages: List<String>.from(data['languages'] ?? []),
      clinics: List<String>.from(data['clinics'] ?? []),
      availableSlots: List<String>.from(data['availableSlots'] ?? []),
      isCheckedIn: data['isCheckedIn'] ?? false,
      services: List<String>.from(data['services'] ?? []),
       introduction: data['introduction'] ?? '',
      checkedInAt: data['checkedInAt'] != null
          ? (data['checkedInAt'] as Timestamp).toDate()
          : null,
      checkedOutAt: data['checkedOutAt'] != null
          ? (data['checkedOutAt'] as Timestamp).toDate()
          : null,
      lastUpdated: data['lastUpdated'] != null
          ? (data['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'specializations': specializations,
      'education': education,
      'experience': experience,
      'languages': languages,
      'clinics': clinics,
      'availableSlots': availableSlots,
      'isCheckedIn': isCheckedIn,
      'services': services,
      'introduction': introduction,
      'checkedInAt':
          checkedInAt != null ? Timestamp.fromDate(checkedInAt!) : null,
      'checkedOutAt':
          checkedOutAt != null ? Timestamp.fromDate(checkedOutAt!) : null,
      'lastUpdated':
          lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }
}

class DoctorReviewModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String patientName;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  DoctorReviewModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.patientName,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory DoctorReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorReviewModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      comment: data['comment'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'patientId': patientId,
      'patientName': patientName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

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
  final String firstName;
  final String lastName;
  final String email;
  final String? phoneNumber;
  final DoctorSpecialty specialty;
  final String specialtyText;
  final DoctorGender gender;
  final List<String> languages;
  final String? profileImage;
  final String? bio;
  final double rating;
  final int reviewCount;
  final double consultationFee;
  final double videoConsultationFee;
  final String hospitalName;
  final String hospitalAddress;
  final String? city;
  final String? country;
  final List<String> availableDays; // ['monday', 'tuesday', etc.]
  final Map<String, List<String>> timeSlots; // {'monday': ['09:00', '10:00']}
  final bool isAvailableForVideo;
  final bool isAvailableForInClinic;
  final int experienceYears;
  final List<String> qualifications;
  final bool isVerified;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  DoctorModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phoneNumber,
    required this.specialty,
    required this.specialtyText,
    required this.gender,
    required this.languages,
    this.profileImage,
    this.bio,
    required this.rating,
    required this.reviewCount,
    required this.consultationFee,
    required this.videoConsultationFee,
    required this.hospitalName,
    required this.hospitalAddress,
    this.city,
    this.country,
    required this.availableDays,
    required this.timeSlots,
    required this.isAvailableForVideo,
    required this.isAvailableForInClinic,
    required this.experienceYears,
    required this.qualifications,
    required this.isVerified,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  String get fullName => '$firstName $lastName';
  String get displaySpecialty => specialtyText;
  String get genderText => gender.toString().split('.').last;
  String get languagesText => languages.join(', ');

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      id: doc.id,
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      phoneNumber: data['phoneNumber'],
      specialty: DoctorSpecialty.values.firstWhere(
        (e) => e.toString().split('.').last == data['specialty'],
        orElse: () => DoctorSpecialty.generalMedicine,
      ),
      specialtyText: data['specialtyText'] ?? '',
      gender: DoctorGender.values.firstWhere(
        (e) => e.toString().split('.').last == data['gender'],
        orElse: () => DoctorGender.other,
      ),
      languages: List<String>.from(data['languages'] ?? []),
      profileImage: data['profileImage'],
      bio: data['bio'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      consultationFee: (data['consultationFee'] ?? 0.0).toDouble(),
      videoConsultationFee: (data['videoConsultationFee'] ?? 0.0).toDouble(),
      hospitalName: data['hospitalName'] ?? '',
      hospitalAddress: data['hospitalAddress'] ?? '',
      city: data['city'],
      country: data['country'],
      availableDays: List<String>.from(data['availableDays'] ?? []),
      timeSlots: Map<String, List<String>>.from(
        (data['timeSlots'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
      isAvailableForVideo: data['isAvailableForVideo'] ?? false,
      isAvailableForInClinic: data['isAvailableForInClinic'] ?? true,
      experienceYears: data['experienceYears'] ?? 0,
      qualifications: List<String>.from(data['qualifications'] ?? []),
      isVerified: data['isVerified'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'phoneNumber': phoneNumber,
      'specialty': specialty.toString().split('.').last,
      'specialtyText': specialtyText,
      'gender': gender.toString().split('.').last,
      'languages': languages,
      'profileImage': profileImage,
      'bio': bio,
      'rating': rating,
      'reviewCount': reviewCount,
      'consultationFee': consultationFee,
      'videoConsultationFee': videoConsultationFee,
      'hospitalName': hospitalName,
      'hospitalAddress': hospitalAddress,
      'city': city,
      'country': country,
      'availableDays': availableDays,
      'timeSlots': timeSlots,
      'isAvailableForVideo': isAvailableForVideo,
      'isAvailableForInClinic': isAvailableForInClinic,
      'experienceYears': experienceYears,
      'qualifications': qualifications,
      'isVerified': isVerified,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
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
import 'package:cloud_firestore/cloud_firestore.dart';

enum RecordType {
  labResult,
  scanReport,
  prescription,
  consultation,
  vaccination,
  surgery,
  allergy,
  chronicCondition,
  vitals,
  other,
}

class MedicalRecordModel {
  final String id;
  final String patientId;
  final String? familyMemberId;
  final RecordType type;
  final String title;
  final String description;
  final String? doctorName;
  final String? hospitalName;
  final DateTime recordDate;
  final String? pdfBase64;
  final String? imageBase64;
  final Map<String, dynamic>? labValues;
  final List<String> tags;
  final bool isShared;
  final DateTime createdAt;
  final DateTime? updatedAt;

  MedicalRecordModel({
    required this.id,
    required this.patientId,
    this.familyMemberId,
    required this.type,
    required this.title,
    required this.description,
    this.doctorName,
    this.hospitalName,
    required this.recordDate,
    this.pdfBase64,
    this.imageBase64,
    this.labValues,
    required this.tags,
    required this.isShared,
    required this.createdAt,
    this.updatedAt,
  });

  String get typeText {
    switch (type) {
      case RecordType.labResult:
        return 'Lab Result';
      case RecordType.scanReport:
        return 'Scan Report';
      case RecordType.prescription:
        return 'Prescription';
      case RecordType.consultation:
        return 'Consultation';
      case RecordType.vaccination:
        return 'Vaccination';
      case RecordType.surgery:
        return 'Surgery';
      case RecordType.allergy:
        return 'Allergy';
      case RecordType.chronicCondition:
        return 'Chronic Condition';
      case RecordType.vitals:
        return 'Vitals';
      case RecordType.other:
        return 'Other';
    }
  }

  bool get hasPdf => pdfBase64 != null && pdfBase64!.isNotEmpty;
  bool get hasImage => imageBase64 != null && imageBase64!.isNotEmpty;

  factory MedicalRecordModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicalRecordModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      familyMemberId: data['familyMemberId'],
      type: RecordType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => RecordType.other,
      ),
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      doctorName: data['doctorName'],
      hospitalName: data['hospitalName'],
      recordDate: (data['recordDate'] as Timestamp).toDate(),
      pdfBase64: data['pdfBase64'],
      imageBase64: data['imageBase64'],
      labValues: data['labValues'] != null 
          ? Map<String, dynamic>.from(data['labValues']) 
          : null,
      tags: List<String>.from(data['tags'] ?? []),
      isShared: data['isShared'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'familyMemberId': familyMemberId,
      'type': type.toString().split('.').last,
      'title': title,
      'description': description,
      'doctorName': doctorName,
      'hospitalName': hospitalName,
      'recordDate': Timestamp.fromDate(recordDate),
      'pdfBase64': pdfBase64,
      'imageBase64': imageBase64,
      'labValues': labValues,
      'tags': tags,
      'isShared': isShared,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}

class HealthPackageModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final List<String> includedTests;
  final String? imageUrl;
  final int duration;
  final bool isPopular;
  final String category;
  final List<String> benefits;
  final DateTime createdAt;

  HealthPackageModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.includedTests,
    this.imageUrl,
    required this.duration,
    required this.isPopular,
    required this.category,
    required this.benefits,
    required this.createdAt,
  });

  double get finalPrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  factory HealthPackageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return HealthPackageModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      discountPrice: data['discountPrice']?.toDouble(),
      includedTests: List<String>.from(data['includedTests'] ?? []),
      imageUrl: data['imageUrl'],
      duration: data['duration'] ?? 0,
      isPopular: data['isPopular'] ?? false,
      category: data['category'] ?? '',
      benefits: List<String>.from(data['benefits'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'includedTests': includedTests,
      'imageUrl': imageUrl,
      'duration': duration,
      'isPopular': isPopular,
      'category': category,
      'benefits': benefits,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
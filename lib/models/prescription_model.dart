import 'package:cloud_firestore/cloud_firestore.dart';

enum PrescriptionStatus { active, completed, cancelled, renewalRequested }

class MedicationModel {
  final String name;
  final String dosage;
  final String frequency;
  final String instructions;
  final int duration; // in days

  MedicationModel({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.instructions,
    required this.duration,
  });

  factory MedicationModel.fromMap(Map<String, dynamic> data) {
    return MedicationModel(
      name: data['name'] ?? '',
      dosage: data['dosage'] ?? '',
      frequency: data['frequency'] ?? '',
      instructions: data['instructions'] ?? '',
      duration: data['duration'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'instructions': instructions,
      'duration': duration,
    };
  }
}

class PrescriptionModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final List<MedicationModel> medications;
  final PrescriptionStatus status;
  final DateTime prescribedDate;
  final DateTime? completedDate;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PrescriptionModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.medications,
    required this.status,
    required this.prescribedDate,
    this.completedDate,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory PrescriptionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PrescriptionModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      medications: (data['medications'] as List<dynamic>?)
          ?.map((med) => MedicationModel.fromMap(med as Map<String, dynamic>))
          .toList() ?? [],
      status: PrescriptionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => PrescriptionStatus.active,
      ),
      prescribedDate: (data['prescribedDate'] as Timestamp).toDate(),
      completedDate: data['completedDate'] != null 
          ? (data['completedDate'] as Timestamp).toDate() 
          : null,
      notes: data['notes'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'medications': medications.map((med) => med.toMap()).toList(),
      'status': status.toString().split('.').last,
      'prescribedDate': Timestamp.fromDate(prescribedDate),
      'completedDate': completedDate != null 
          ? Timestamp.fromDate(completedDate!) 
          : null,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  String get statusText {
    switch (status) {
      case PrescriptionStatus.active:
        return 'Active';
      case PrescriptionStatus.completed:
        return 'Completed';
      case PrescriptionStatus.cancelled:
        return 'Cancelled';
      case PrescriptionStatus.renewalRequested:
        return 'Renewal Requested';
    }
  }

  bool get canRequestRenewal {
    return status == PrescriptionStatus.active || 
           status == PrescriptionStatus.completed;
  }
}
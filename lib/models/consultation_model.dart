import 'package:cloud_firestore/cloud_firestore.dart';

class ConsultationModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final DateTime consultationDate;
  final String chiefComplaint;
  final String diagnosis;
  final String treatment;
  final String notes;
  final List<String> symptoms;
  final Map<String, String> vitals; // e.g., {"bp": "120/80", "temp": "98.6"}
  final String? followUpInstructions;
  final DateTime? nextAppointment;
  final String? reportPdf; // Base64 encoded PDF
  final DateTime createdAt;
  final DateTime? updatedAt;

  ConsultationModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.consultationDate,
    required this.chiefComplaint,
    required this.diagnosis,
    required this.treatment,
    required this.notes,
    required this.symptoms,
    required this.vitals,
    this.followUpInstructions,
    this.nextAppointment,
    this.reportPdf,
    required this.createdAt,
    this.updatedAt,
  });

  factory ConsultationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ConsultationModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorSpecialty: data['doctorSpecialty'] ?? '',
      consultationDate: (data['consultationDate'] as Timestamp).toDate(),
      chiefComplaint: data['chiefComplaint'] ?? '',
      diagnosis: data['diagnosis'] ?? '',
      treatment: data['treatment'] ?? '',
      notes: data['notes'] ?? '',
      symptoms: List<String>.from(data['symptoms'] ?? []),
      vitals: Map<String, String>.from(data['vitals'] ?? {}),
      followUpInstructions: data['followUpInstructions'],
      nextAppointment: data['nextAppointment'] != null 
          ? (data['nextAppointment'] as Timestamp).toDate() 
          : null,
      reportPdf: data['reportPdf'],
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
      'doctorSpecialty': doctorSpecialty,
      'consultationDate': Timestamp.fromDate(consultationDate),
      'chiefComplaint': chiefComplaint,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'notes': notes,
      'symptoms': symptoms,
      'vitals': vitals,
      'followUpInstructions': followUpInstructions,
      'nextAppointment': nextAppointment != null 
          ? Timestamp.fromDate(nextAppointment!) 
          : null,
      'reportPdf': reportPdf,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  bool get hasReport => reportPdf != null && reportPdf!.isNotEmpty;
  
  bool get hasFollowUp => nextAppointment != null;
}
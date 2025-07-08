import 'package:cloud_firestore/cloud_firestore.dart';

enum CallStatus {
  scheduled,
  ongoing,
  completed,
  cancelled,
  missed,
}

enum CallType {
  consultation,
  followUp,
  emergency,
}

class VideoCallModel {
  final String id;
  final String appointmentId;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final CallType type;
  final CallStatus status;
  final DateTime scheduledTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final int? duration; // in minutes
  final String? channelName;
  final String? token;
  final String? recordingUrl;
  final String? notes;
  final double? rating;
  final String? feedback;
  final DateTime createdAt;
  final DateTime? updatedAt;

  VideoCallModel({
    required this.id,
    required this.appointmentId,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.type,
    required this.status,
    required this.scheduledTime,
    this.startTime,
    this.endTime,
    this.duration,
    this.channelName,
    this.token,
    this.recordingUrl,
    this.notes,
    this.rating,
    this.feedback,
    required this.createdAt,
    this.updatedAt,
  });

  String get statusText {
    switch (status) {
      case CallStatus.scheduled:
        return 'Scheduled';
      case CallStatus.ongoing:
        return 'Ongoing';
      case CallStatus.completed:
        return 'Completed';
      case CallStatus.cancelled:
        return 'Cancelled';
      case CallStatus.missed:
        return 'Missed';
    }
  }

  String get typeText {
    switch (type) {
      case CallType.consultation:
        return 'Consultation';
      case CallType.followUp:
        return 'Follow-up';
      case CallType.emergency:
        return 'Emergency';
    }
  }

  bool get canJoin => status == CallStatus.scheduled && 
      DateTime.now().isAfter(scheduledTime.subtract(const Duration(minutes: 5)));

  factory VideoCallModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VideoCallModel(
      id: doc.id,
      appointmentId: data['appointmentId'] ?? '',
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      type: CallType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => CallType.consultation,
      ),
      status: CallStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => CallStatus.scheduled,
      ),
      scheduledTime: (data['scheduledTime'] as Timestamp).toDate(),
      startTime: data['startTime'] != null 
          ? (data['startTime'] as Timestamp).toDate() 
          : null,
      endTime: data['endTime'] != null 
          ? (data['endTime'] as Timestamp).toDate() 
          : null,
      duration: data['duration'],
      channelName: data['channelName'],
      token: data['token'],
      recordingUrl: data['recordingUrl'],
      notes: data['notes'],
      rating: data['rating']?.toDouble(),
      feedback: data['feedback'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'appointmentId': appointmentId,
      'patientId': patientId,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'duration': duration,
      'channelName': channelName,
      'token': token,
      'recordingUrl': recordingUrl,
      'notes': notes,
      'rating': rating,
      'feedback': feedback,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
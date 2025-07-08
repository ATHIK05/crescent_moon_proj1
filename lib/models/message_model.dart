import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file }
enum MessageStatus { sent, delivered, read }

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime timestamp;
  final bool isFromPatient;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.type,
    required this.status,
    required this.timestamp,
    required this.isFromPatient,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      receiverId: data['receiverId'] ?? '',
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => MessageStatus.sent,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isFromPatient: data['isFromPatient'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'isFromPatient': isFromPatient,
    };
  }
}

class ChatModel {
  final String id;
  final String patientId;
  final String doctorId;
  final String doctorName;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ChatModel({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    this.lastMessage,
    this.lastMessageTime,
    required this.unreadCount,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime'] != null 
          ? (data['lastMessageTime'] as Timestamp).toDate() 
          : null,
      unreadCount: data['unreadCount'] ?? 0,
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
      'lastMessage': lastMessage,
      'lastMessageTime': lastMessageTime != null 
          ? Timestamp.fromDate(lastMessageTime!) 
          : null,
      'unreadCount': unreadCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
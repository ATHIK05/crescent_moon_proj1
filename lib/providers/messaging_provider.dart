import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message_model.dart';

class MessagingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ChatModel> _chats = [];
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatModel> get chats => _chats;
  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  MessagingProvider() {
    _loadChats();
  }

  void _loadChats() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('chats')
        .where('patientId', isEqualTo: user.uid)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _chats = snapshot.docs
          .map((doc) => ChatModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  void loadMessages(String chatId) {
    _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _messages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  Future<bool> sendMessage({
    required String chatId,
    required String receiverId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final message = MessageModel(
        id: '',
        senderId: user.uid,
        receiverId: receiverId,
        content: content,
        type: type,
        status: MessageStatus.sent,
        timestamp: DateTime.now(),
        isFromPatient: true,
      );

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toFirestore());

      // Update chat with last message
      await _firestore
          .collection('chats')
          .doc(chatId)
          .update({
        'lastMessage': content,
        'lastMessageTime': Timestamp.fromDate(DateTime.now()),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to send message: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
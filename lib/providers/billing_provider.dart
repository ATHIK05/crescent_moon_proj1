import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bill_model.dart';

class BillingProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<BillModel> _bills = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<BillModel> get bills => _bills;
  List<BillModel> get pendingBills => 
      _bills.where((b) => b.status == BillStatus.pending).toList();
  List<BillModel> get overdueBills => 
      _bills.where((b) => b.isOverdue).toList();
  double get totalPendingAmount => 
      pendingBills.fold(0.0, (sum, bill) => sum + bill.totalAmount);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  BillingProvider() {
    _loadBills();
  }

  void _loadBills() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('bills')
        .where('patientId', isEqualTo: user.uid)
        .orderBy('billDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _bills = snapshot.docs
          .map((doc) => BillModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
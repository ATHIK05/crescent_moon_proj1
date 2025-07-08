import 'package:cloud_firestore/cloud_firestore.dart';

enum BillStatus { pending, paid, overdue, cancelled }
enum BillType { consultation, medication, procedure, insurance }

class BillItemModel {
  final String description;
  final double amount;
  final int quantity;

  BillItemModel({
    required this.description,
    required this.amount,
    required this.quantity,
  });

  double get total => amount * quantity;

  factory BillItemModel.fromMap(Map<String, dynamic> data) {
    return BillItemModel(
      description: data['description'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      quantity: data['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'amount': amount,
      'quantity': quantity,
    };
  }
}

class BillModel {
  final String id;
  final String patientId;
  final String billNumber;
  final List<BillItemModel> items;
  final double subtotal;
  final double tax;
  final double discount;
  final double totalAmount;
  final BillStatus status;
  final BillType type;
  final DateTime billDate;
  final DateTime dueDate;
  final DateTime? paidDate;
  final String? paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BillModel({
    required this.id,
    required this.patientId,
    required this.billNumber,
    required this.items,
    required this.subtotal,
    required this.tax,
    required this.discount,
    required this.totalAmount,
    required this.status,
    required this.type,
    required this.billDate,
    required this.dueDate,
    this.paidDate,
    this.paymentMethod,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory BillModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BillModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      billNumber: data['billNumber'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => BillItemModel.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      subtotal: (data['subtotal'] ?? 0).toDouble(),
      tax: (data['tax'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      status: BillStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => BillStatus.pending,
      ),
      type: BillType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => BillType.consultation,
      ),
      billDate: (data['billDate'] as Timestamp).toDate(),
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      paidDate: data['paidDate'] != null 
          ? (data['paidDate'] as Timestamp).toDate() 
          : null,
      paymentMethod: data['paymentMethod'],
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
      'billNumber': billNumber,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'discount': discount,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      'billDate': Timestamp.fromDate(billDate),
      'dueDate': Timestamp.fromDate(dueDate),
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  String get statusText {
    switch (status) {
      case BillStatus.pending:
        return 'Pending';
      case BillStatus.paid:
        return 'Paid';
      case BillStatus.overdue:
        return 'Overdue';
      case BillStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get typeText {
    switch (type) {
      case BillType.consultation:
        return 'Consultation';
      case BillType.medication:
        return 'Medication';
      case BillType.procedure:
        return 'Procedure';
      case BillType.insurance:
        return 'Insurance';
    }
  }

  bool get isOverdue {
    return status == BillStatus.pending && 
           DateTime.now().isAfter(dueDate);
  }

  bool get isPaid {
    return status == BillStatus.paid;
  }
}
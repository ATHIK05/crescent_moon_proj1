import 'package:cloud_firestore/cloud_firestore.dart';

enum ProductCategory {
  medicines,
  vitamins,
  supplements,
  skincare,
  personalCare,
  babycare,
  fitness,
  medicalDevices,
  firstAid,
  wellness,
}

enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
}

class PharmacyProductModel {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final ProductCategory category;
  final double price;
  final double? discountPrice;
  final int discountPercentage;
  final bool isPrescriptionRequired;
  final bool isInStock;
  final int stockQuantity;
  final String manufacturer;
  final String? dosage;
  final String? packSize;
  final List<String> ingredients;
  final String? usage;
  final String? sideEffects;
  final String? warnings;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PharmacyProductModel({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.category,
    required this.price,
    this.discountPrice,
    required this.discountPercentage,
    required this.isPrescriptionRequired,
    required this.isInStock,
    required this.stockQuantity,
    required this.manufacturer,
    this.dosage,
    this.packSize,
    required this.ingredients,
    this.usage,
    this.sideEffects,
    this.warnings,
    required this.rating,
    required this.reviewCount,
    required this.isFeatured,
    required this.createdAt,
    this.updatedAt,
  });

  double get finalPrice => discountPrice ?? price;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  String get categoryText => category.toString().split('.').last;

  factory PharmacyProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PharmacyProductModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'],
      category: ProductCategory.values.firstWhere(
        (e) => e.toString().split('.').last == data['category'],
        orElse: () => ProductCategory.medicines,
      ),
      price: (data['price'] ?? 0.0).toDouble(),
      discountPrice: data['discountPrice']?.toDouble(),
      discountPercentage: data['discountPercentage'] ?? 0,
      isPrescriptionRequired: data['isPrescriptionRequired'] ?? false,
      isInStock: data['isInStock'] ?? true,
      stockQuantity: data['stockQuantity'] ?? 0,
      manufacturer: data['manufacturer'] ?? '',
      dosage: data['dosage'],
      packSize: data['packSize'],
      ingredients: List<String>.from(data['ingredients'] ?? []),
      usage: data['usage'],
      sideEffects: data['sideEffects'],
      warnings: data['warnings'],
      rating: (data['rating'] ?? 0.0).toDouble(),
      reviewCount: data['reviewCount'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'category': category.toString().split('.').last,
      'price': price,
      'discountPrice': discountPrice,
      'discountPercentage': discountPercentage,
      'isPrescriptionRequired': isPrescriptionRequired,
      'isInStock': isInStock,
      'stockQuantity': stockQuantity,
      'manufacturer': manufacturer,
      'dosage': dosage,
      'packSize': packSize,
      'ingredients': ingredients,
      'usage': usage,
      'sideEffects': sideEffects,
      'warnings': warnings,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}

class CartItemModel {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? imageUrl;
  final bool isPrescriptionRequired;

  CartItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.imageUrl,
    required this.isPrescriptionRequired,
  });

  double get totalPrice => price * quantity;

  factory CartItemModel.fromMap(Map<String, dynamic> data) {
    return CartItemModel(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      price: (data['price'] ?? 0.0).toDouble(),
      quantity: data['quantity'] ?? 1,
      imageUrl: data['imageUrl'],
      isPrescriptionRequired: data['isPrescriptionRequired'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
      'isPrescriptionRequired': isPrescriptionRequired,
    };
  }
}

class PharmacyOrderModel {
  final String id;
  final String patientId;
  final List<CartItemModel> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double totalAmount;
  final OrderStatus status;
  final String deliveryAddress;
  final String? deliveryInstructions;
  final String? prescriptionImageUrl;
  final DateTime orderDate;
  final DateTime? estimatedDeliveryDate;
  final DateTime? deliveredDate;
  final String? trackingNumber;
  final String? paymentMethod;
  final bool isPaid;
  final int loyaltyPointsEarned;
  final int loyaltyPointsUsed;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PharmacyOrderModel({
    required this.id,
    required this.patientId,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    this.deliveryInstructions,
    this.prescriptionImageUrl,
    required this.orderDate,
    this.estimatedDeliveryDate,
    this.deliveredDate,
    this.trackingNumber,
    this.paymentMethod,
    required this.isPaid,
    required this.loyaltyPointsEarned,
    required this.loyaltyPointsUsed,
    required this.createdAt,
    this.updatedAt,
  });

  String get statusText {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  bool get canCancel => status == OrderStatus.pending || status == OrderStatus.confirmed;
  bool get isDelivered => status == OrderStatus.delivered;

  factory PharmacyOrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PharmacyOrderModel(
      id: doc.id,
      patientId: data['patientId'] ?? '',
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => CartItemModel.fromMap(item as Map<String, dynamic>))
          .toList() ?? [],
      subtotal: (data['subtotal'] ?? 0.0).toDouble(),
      deliveryFee: (data['deliveryFee'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: data['deliveryAddress'] ?? '',
      deliveryInstructions: data['deliveryInstructions'],
      prescriptionImageUrl: data['prescriptionImageUrl'],
      orderDate: (data['orderDate'] as Timestamp).toDate(),
      estimatedDeliveryDate: data['estimatedDeliveryDate'] != null 
          ? (data['estimatedDeliveryDate'] as Timestamp).toDate() 
          : null,
      deliveredDate: data['deliveredDate'] != null 
          ? (data['deliveredDate'] as Timestamp).toDate() 
          : null,
      trackingNumber: data['trackingNumber'],
      paymentMethod: data['paymentMethod'],
      isPaid: data['isPaid'] ?? false,
      loyaltyPointsEarned: data['loyaltyPointsEarned'] ?? 0,
      loyaltyPointsUsed: data['loyaltyPointsUsed'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: data['updatedAt'] != null 
          ? (data['updatedAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientId': patientId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'discount': discount,
      'totalAmount': totalAmount,
      'status': status.toString().split('.').last,
      'deliveryAddress': deliveryAddress,
      'deliveryInstructions': deliveryInstructions,
      'prescriptionImageUrl': prescriptionImageUrl,
      'orderDate': Timestamp.fromDate(orderDate),
      'estimatedDeliveryDate': estimatedDeliveryDate != null 
          ? Timestamp.fromDate(estimatedDeliveryDate!) 
          : null,
      'deliveredDate': deliveredDate != null 
          ? Timestamp.fromDate(deliveredDate!) 
          : null,
      'trackingNumber': trackingNumber,
      'paymentMethod': paymentMethod,
      'isPaid': isPaid,
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'loyaltyPointsUsed': loyaltyPointsUsed,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }
}
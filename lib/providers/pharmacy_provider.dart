import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/pharmacy_model.dart';

class PharmacyProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<PharmacyProductModel> _products = [];
  List<PharmacyProductModel> _filteredProducts = [];
  List<CartItemModel> _cartItems = [];
  List<PharmacyOrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  int _loyaltyPoints = 0;

  // Filter properties
  String _searchQuery = '';
  ProductCategory? _selectedCategory;
  bool _prescriptionRequiredOnly = false;
  double _minPrice = 0.0;
  double _maxPrice = 1000.0;

  List<PharmacyProductModel> get products => _products;
  List<PharmacyProductModel> get filteredProducts => _filteredProducts;
  List<CartItemModel> get cartItems => _cartItems;
  List<PharmacyOrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get loyaltyPoints => _loyaltyPoints;

  int get cartItemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get cartTotal => _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);

  ProductCategory? get selectedCategory => _selectedCategory;

  PharmacyProvider() {
    _loadProducts();
    _loadOrders();
    _loadLoyaltyPoints();
  }

  void _loadProducts() {
    _firestore
        .collection('pharmacy_products')
        .where('isInStock', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _products = snapshot.docs
          .map((doc) => PharmacyProductModel.fromFirestore(doc))
          .toList();
      _applyFilters();
      notifyListeners();
    });
  }

  void _loadOrders() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('pharmacy_orders')
        .where('patientId', isEqualTo: user.uid)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .listen((snapshot) {
      _orders = snapshot.docs
          .map((doc) => PharmacyOrderModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    });
  }

  void _loadLoyaltyPoints() {
    final user = _auth.currentUser;
    if (user == null) return;

    _firestore
        .collection('patients')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        _loyaltyPoints = data['loyaltyPoints'] ?? 0;
        notifyListeners();
      }
    });
  }

  void searchProducts(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void filterByCategory(ProductCategory? category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void filterByPrescriptionRequired(bool prescriptionOnly) {
    _prescriptionRequiredOnly = prescriptionOnly;
    _applyFilters();
    notifyListeners();
  }

  void filterByPriceRange(double minPrice, double maxPrice) {
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _prescriptionRequiredOnly = false;
    _minPrice = 0.0;
    _maxPrice = 1000.0;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredProducts = _products.where((product) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!product.name.toLowerCase().contains(query) &&
            !product.description.toLowerCase().contains(query) &&
            !product.manufacturer.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && product.category != _selectedCategory) {
        return false;
      }

      // Prescription required filter
      if (_prescriptionRequiredOnly && !product.isPrescriptionRequired) {
        return false;
      }

      // Price range filter
      if (product.finalPrice < _minPrice || product.finalPrice > _maxPrice) {
        return false;
      }

      return true;
    }).toList();

    // Sort by featured, then by rating
    _filteredProducts.sort((a, b) {
      if (a.isFeatured && !b.isFeatured) return -1;
      if (!a.isFeatured && b.isFeatured) return 1;
      return b.rating.compareTo(a.rating);
    });
  }

  void addToCart(PharmacyProductModel product, int quantity) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.productId == product.id,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex] = CartItemModel(
        productId: product.id,
        productName: product.name,
        price: product.finalPrice,
        quantity: _cartItems[existingIndex].quantity + quantity,
        imageUrl: product.imageUrl,
        isPrescriptionRequired: product.isPrescriptionRequired,
      );
    } else {
      _cartItems.add(CartItemModel(
        productId: product.id,
        productName: product.name,
        price: product.finalPrice,
        quantity: quantity,
        imageUrl: product.imageUrl,
        isPrescriptionRequired: product.isPrescriptionRequired,
      ));
    }

    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      _cartItems[index] = CartItemModel(
        productId: _cartItems[index].productId,
        productName: _cartItems[index].productName,
        price: _cartItems[index].price,
        quantity: quantity,
        imageUrl: _cartItems[index].imageUrl,
        isPrescriptionRequired: _cartItems[index].isPrescriptionRequired,
      );
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  Future<bool> placeOrder({
    required String deliveryAddress,
    String? deliveryInstructions,
    String? prescriptionImageUrl,
    int loyaltyPointsToUse = 0,
  }) async {
    final user = _auth.currentUser;
    if (user == null || _cartItems.isEmpty) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final subtotal = cartTotal;
      final deliveryFee = subtotal > 100 ? 0.0 : 15.0; // Free delivery over AED 100
      final loyaltyDiscount = loyaltyPointsToUse * 0.1; // 1 point = 0.1 AED
      final totalAmount = subtotal + deliveryFee - loyaltyDiscount;
      final loyaltyPointsEarned = (totalAmount * 0.01).round(); // 1% back as points

      final order = PharmacyOrderModel(
        id: '',
        patientId: user.uid,
        items: List.from(_cartItems),
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        discount: loyaltyDiscount,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        deliveryAddress: deliveryAddress,
        deliveryInstructions: deliveryInstructions,
        prescriptionImageUrl: prescriptionImageUrl,
        orderDate: DateTime.now(),
        estimatedDeliveryDate: DateTime.now().add(const Duration(days: 2)),
        isPaid: false,
        loyaltyPointsEarned: loyaltyPointsEarned,
        loyaltyPointsUsed: loyaltyPointsToUse,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('pharmacy_orders').add(order.toFirestore());

      // Update loyalty points
      await _firestore.collection('patients').doc(user.uid).update({
        'loyaltyPoints': FieldValue.increment(loyaltyPointsEarned - loyaltyPointsToUse),
      });

      clearCart();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to place order: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelOrder(String orderId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('pharmacy_orders').doc(orderId).update({
        'status': OrderStatus.cancelled.toString().split('.').last,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return true;
    } catch (e) {
      _errorMessage = 'Failed to cancel order: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<String> getAllCategories() {
    return ProductCategory.values
        .map((category) => category.toString().split('.').last)
        .toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
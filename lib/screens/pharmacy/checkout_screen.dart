import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/pharmacy_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _instructionsController = TextEditingController();
  
  int _loyaltyPointsToUse = 0;
  XFile? _prescriptionImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    if (user?.address != null) {
      _addressController.text = user!.address!;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
      ),
      body: Consumer<PharmacyProvider>(
        builder: (context, pharmacyProvider, child) {
          final subtotal = pharmacyProvider.cartTotal;
          final deliveryFee = subtotal > 100 ? 0.0 : 15.0;
          final loyaltyDiscount = _loyaltyPointsToUse * 0.1;
          final total = subtotal + deliveryFee - loyaltyDiscount;
          final hasPrescriptionItems = pharmacyProvider.cartItems
              .any((item) => item.isPrescriptionRequired);

          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Order Summary
                        Text(
                          'Order Summary',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                ...pharmacyProvider.cartItems.map((item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${item.productName} x${item.quantity}',
                                          style: Theme.of(context).textTheme.bodyMedium,
                                        ),
                                      ),
                                      Text(
                                        'AED ${item.totalPrice.toStringAsFixed(2)}',
                                        style: Theme.of(context).textTheme.bodyMedium,
                                      ),
                                    ],
                                  ),
                                )),
                                const Divider(),
                                _buildSummaryRow('Subtotal', subtotal),
                                _buildSummaryRow('Delivery Fee', deliveryFee),
                                if (_loyaltyPointsToUse > 0)
                                  _buildSummaryRow('Loyalty Discount', -loyaltyDiscount),
                                const Divider(),
                                _buildSummaryRow('Total', total, isTotal: true),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Delivery Address
                        Text(
                          'Delivery Address',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _addressController,
                          label: 'Delivery Address',
                          maxLines: 3,
                          prefixIcon: Icons.location_on,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter delivery address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _instructionsController,
                          label: 'Delivery Instructions (Optional)',
                          maxLines: 2,
                          prefixIcon: Icons.note,
                        ),
                        const SizedBox(height: 24),

                        // Prescription Upload
                        if (hasPrescriptionItems) ...[
                          Text(
                            'Prescription Upload',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.warning,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Your order contains prescription items. Please upload a valid prescription.',
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _pickPrescriptionImage,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.grey.shade300,
                                  style: BorderStyle.solid,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    _prescriptionImage != null 
                                        ? Icons.check_circle 
                                        : Icons.camera_alt,
                                    size: 48,
                                    color: _prescriptionImage != null 
                                        ? Colors.green 
                                        : Colors.grey,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _prescriptionImage != null 
                                        ? 'Prescription Uploaded' 
                                        : 'Upload Prescription',
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  Text(
                                    _prescriptionImage != null 
                                        ? 'Tap to change' 
                                        : 'Take a photo or select from gallery',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Loyalty Points
                        Text(
                          'Loyalty Points',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.stars,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Available Points: ${pharmacyProvider.loyaltyPoints}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Use points for discount (10 points = AED 1)',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Slider(
                                        value: _loyaltyPointsToUse.toDouble(),
                                        min: 0,
                                        max: pharmacyProvider.loyaltyPoints.toDouble(),
                                        divisions: pharmacyProvider.loyaltyPoints > 0 
                                            ? pharmacyProvider.loyaltyPoints 
                                            : 1,
                                        label: '$_loyaltyPointsToUse points',
                                        onChanged: (value) {
                                          setState(() {
                                            _loyaltyPointsToUse = value.round();
                                          });
                                        },
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '$_loyaltyPointsToUse pts',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (_loyaltyPointsToUse > 0)
                                  Text(
                                    'Discount: AED ${loyaltyDiscount.toStringAsFixed(2)}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Place Order Button
                Container(
                  padding: const EdgeInsets.all(16),
                  child: CustomButton(
                    text: 'Place Order - AED ${total.toStringAsFixed(2)}',
                    onPressed: () => _placeOrder(pharmacyProvider),
                    isLoading: pharmacyProvider.isLoading,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            amount == 0 && label == 'Delivery Fee' 
                ? 'FREE' 
                : 'AED ${amount.toStringAsFixed(2)}',
            style: isTotal
                ? Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: amount == 0 && label == 'Delivery Fee' ? Colors.green : null,
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPrescriptionImage() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () async {
                Navigator.of(context).pop();
                final image = await _picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    _prescriptionImage = image;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.of(context).pop();
                final image = await _picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _prescriptionImage = image;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(PharmacyProvider pharmacyProvider) async {
    if (!_formKey.currentState!.validate()) return;

    final hasPrescriptionItems = pharmacyProvider.cartItems
        .any((item) => item.isPrescriptionRequired);

    if (hasPrescriptionItems && _prescriptionImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload a prescription for prescription items'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await pharmacyProvider.placeOrder(
      deliveryAddress: _addressController.text.trim(),
      deliveryInstructions: _instructionsController.text.trim().isNotEmpty 
          ? _instructionsController.text.trim() 
          : null,
      prescriptionImageUrl: _prescriptionImage?.path, // In real app, upload to storage first
      loyaltyPointsToUse: _loyaltyPointsToUse,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Order placed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(pharmacyProvider.errorMessage ?? 'Failed to place order'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
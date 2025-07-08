import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/pharmacy_model.dart';
import '../../providers/pharmacy_provider.dart';
import '../../widgets/custom_button.dart';

class ProductDetailScreen extends StatefulWidget {
  final PharmacyProductModel product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Share product
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: widget.product.imageUrl != null
                  ? Image.network(
                      widget.product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.medical_services, size: 80);
                      },
                    )
                  : const Icon(Icons.medical_services, size: 80),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Name and Price
                  Text(
                    widget.product.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  
                  Row(
                    children: [
                      if (widget.product.hasDiscount) ...[
                        Text(
                          'AED ${widget.product.price.toStringAsFixed(2)}',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${widget.product.discountPercentage}% OFF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    'AED ${widget.product.finalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Stock Status
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: widget.product.isInStock 
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.product.isInStock 
                          ? 'In Stock (${widget.product.stockQuantity} available)'
                          : 'Out of Stock',
                      style: TextStyle(
                        color: widget.product.isInStock ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Prescription Required
                  if (widget.product.isPrescriptionRequired)
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
                              'Prescription Required',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24),
                  
                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  
                  // Product Details
                  _buildDetailSection('Manufacturer', widget.product.manufacturer),
                  if (widget.product.dosage != null)
                    _buildDetailSection('Dosage', widget.product.dosage!),
                  if (widget.product.packSize != null)
                    _buildDetailSection('Pack Size', widget.product.packSize!),
                  
                  // Ingredients
                  if (widget.product.ingredients.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Ingredients',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.ingredients.join(', '),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  
                  // Usage
                  if (widget.product.usage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Usage',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.usage!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  
                  // Side Effects
                  if (widget.product.sideEffects != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Side Effects',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.product.sideEffects!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                  
                  // Warnings
                  if (widget.product.warnings != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Warnings',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        widget.product.warnings!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: widget.product.isInStock
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          '$_quantity',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        IconButton(
                          onPressed: _quantity < widget.product.stockQuantity
                              ? () => setState(() => _quantity++)
                              : null,
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Add to Cart Button
                  Expanded(
                    child: CustomButton(
                      text: 'Add to Cart - AED ${(widget.product.finalPrice * _quantity).toStringAsFixed(2)}',
                      onPressed: () {
                        Provider.of<PharmacyProvider>(context, listen: false)
                            .addToCart(widget.product, _quantity);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${widget.product.name} added to cart'),
                            backgroundColor: Colors.green,
                            action: SnackBarAction(
                              label: 'View Cart',
                              onPressed: () {
                                Navigator.of(context).pushNamed('/cart');
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  Widget _buildDetailSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
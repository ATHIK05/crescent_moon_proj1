import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  late TextEditingController _insuranceProviderController;
  late TextEditingController _insuranceNumberController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).userModel;
    
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _phoneController = TextEditingController(text: user?.phoneNumber ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
    _emergencyContactController = TextEditingController(text: user?.emergencyContact ?? '');
    _insuranceProviderController = TextEditingController(text: user?.insuranceProvider ?? '');
    _insuranceNumberController = TextEditingController(text: user?.insuranceNumber ?? '');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _insuranceProviderController.dispose();
    _insuranceNumberController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.userModel;
    
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isNotEmpty 
          ? _phoneController.text.trim() 
          : null,
      address: _addressController.text.trim().isNotEmpty 
          ? _addressController.text.trim() 
          : null,
      emergencyContact: _emergencyContactController.text.trim().isNotEmpty 
          ? _emergencyContactController.text.trim() 
          : null,
      insuranceProvider: _insuranceProviderController.text.trim().isNotEmpty 
          ? _insuranceProviderController.text.trim() 
          : null,
      insuranceNumber: _insuranceNumberController.text.trim().isNotEmpty 
          ? _insuranceNumberController.text.trim() 
          : null,
      updatedAt: DateTime.now(),
    );

    final success = await authProvider.updateProfile(updatedUser);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to update profile'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      prefixIcon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _phoneController,
                label: 'Phone Number',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _addressController,
                label: 'Address',
                maxLines: 3,
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 24),
              Text(
                'Emergency Contact',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emergencyContactController,
                label: 'Emergency Contact',
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.emergency,
              ),
              const SizedBox(height: 24),
              Text(
                'Insurance Information',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _insuranceProviderController,
                label: 'Insurance Provider',
                prefixIcon: Icons.local_hospital,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _insuranceNumberController,
                label: 'Insurance Number',
                prefixIcon: Icons.credit_card,
              ),
              const SizedBox(height: 32),
              Consumer<AuthProvider>(
                builder: (context, authProvider, child) {
                  return CustomButton(
                    text: 'Update Profile',
                    onPressed: _updateProfile,
                    isLoading: authProvider.isLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
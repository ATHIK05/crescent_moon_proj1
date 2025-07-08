import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/family_model.dart';
import '../../providers/family_provider.dart';
import '../../widgets/custom_text_field.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => FamilyProvider(),
      child: Scaffold(
        appBar: AppBar(title: const Text('F amily Management')),
        body: Consumer<FamilyProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.familyMembers.isEmpty) {
              return const Center(child: Text('No family members added yet.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.familyMembers.length,
              itemBuilder: (context, index) {
                final member = provider.familyMembers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: member.profileImage != null
                          ? NetworkImage(member.profileImage!)
                          : null,
                      child: member.profileImage == null
                          ? Text(member.firstName[0])
                          : null,
                    ),
                    title: Text(member.fullName),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Relationship: ${member.relationshipText}'),
                        Text('Age: ${member.age} | Gender: ${member.gender}'),
                        if (member.bloodGroupText != null)
                          Text('Blood Group: ${member.bloodGroupText}'),
                        if (member.bmi != null)
                          Text('BMI: ${member.bmi!.toStringAsFixed(1)}'),
                        if (member.allergies.isNotEmpty)
                          Text('Allergies: ${member.allergies.join(", ")}'),
                        if (member.medications.isNotEmpty)
                          Text('Medications: ${member.medications.join(", ")}'),
                        if (member.chronicConditions.isNotEmpty)
                          Text('Chronic: ${member.chronicConditions.join(", ")}'),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          _showAddEditDialog(context, provider, member: member);
                        } else if (value == 'delete') {
                          provider.removeFamilyMember(member.id);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: Consumer<FamilyProvider>(
          builder: (context, provider, child) => FloatingActionButton(
            onPressed: () => _showAddEditDialog(context, provider),
            child: const Icon(Icons.add),
            tooltip: 'Add Family Member',
          ),
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, FamilyProvider provider, {FamilyMemberModel? member}) {
    showDialog(
      context: context,
      builder: (context) => AddEditFamilyMemberDialog(
        provider: provider,
        member: member,
      ),
    );
  }
}

class AddEditFamilyMemberDialog extends StatefulWidget {
  final FamilyProvider provider;
  final FamilyMemberModel? member;
  const AddEditFamilyMemberDialog({super.key, required this.provider, this.member});

  @override
  State<AddEditFamilyMemberDialog> createState() => _AddEditFamilyMemberDialogState();
}

class _AddEditFamilyMemberDialogState extends State<AddEditFamilyMemberDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;
  late final TextEditingController _allergiesController;
  late final TextEditingController _medicationsController;
  late final TextEditingController _chronicController;
  late final TextEditingController _emergencyContactController;
  late final TextEditingController _emergencyPhoneController;
  late final TextEditingController _insuranceProviderController;
  late final TextEditingController _insuranceNumberController;
  late DateTime _dateOfBirth;
  late String _gender;
  late Relationship _relationship;
  BloodGroup? _bloodGroup;

  @override
  void initState() {
    final m = widget.member;
    _firstNameController = TextEditingController(text: m?.firstName ?? '');
    _lastNameController = TextEditingController(text: m?.lastName ?? '');
    _emailController = TextEditingController(text: m?.email ?? '');
    _phoneController = TextEditingController(text: m?.phoneNumber ?? '');
    _heightController = TextEditingController(text: m?.height?.toString() ?? '');
    _weightController = TextEditingController(text: m?.weight?.toString() ?? '');
    _allergiesController = TextEditingController(text: m?.allergies.join(', ') ?? '');
    _medicationsController = TextEditingController(text: m?.medications.join(', ') ?? '');
    _chronicController = TextEditingController(text: m?.chronicConditions.join(', ') ?? '');
    _emergencyContactController = TextEditingController(text: m?.emergencyContact ?? '');
    _emergencyPhoneController = TextEditingController(text: m?.emergencyContactPhone ?? '');
    _insuranceProviderController = TextEditingController(text: m?.insuranceProvider ?? '');
    _insuranceNumberController = TextEditingController(text: m?.insuranceNumber ?? '');
    _dateOfBirth = m?.dateOfBirth ?? DateTime(2000, 1, 1);
    _gender = m?.gender ?? 'Male';
    _relationship = m?.relationship ?? Relationship.child;
    _bloodGroup = m?.bloodGroup;
    super.initState();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _chronicController.dispose();
    _emergencyContactController.dispose();
    _emergencyPhoneController.dispose();
    _insuranceProviderController.dispose();
    _insuranceNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.member == null ? 'Add Family Member' : 'Edit Family Member'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(controller: _firstNameController, label: 'First Name'),
            const SizedBox(height: 8),
            CustomTextField(controller: _lastNameController, label: 'Last Name'),
            const SizedBox(height: 8),
            CustomTextField(controller: _emailController, label: 'Email'),
            const SizedBox(height: 8),
            CustomTextField(controller: _phoneController, label: 'Phone Number'),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('DOB:'),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _dateOfBirth,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _dateOfBirth = picked);
                  },
                  child: Text('${_dateOfBirth.toLocal()}'.split(' ')[0]),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Gender:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _gender,
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setState(() => _gender = v ?? 'Male'),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Relationship:'),
                const SizedBox(width: 8),
                DropdownButton<Relationship>(
                  value: _relationship,
                  items: Relationship.values
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r.toString().split('.').last),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _relationship = v ?? Relationship.child),
                ),
              ],
            ),
            Row(
              children: [
                const Text('Blood Group:'),
                const SizedBox(width: 8),
                DropdownButton<BloodGroup?>(
                  value: _bloodGroup,
                  items: [null, ...BloodGroup.values]
                      .map((b) => DropdownMenuItem(
                            value: b,
                            child: Text(b == null ? 'Unknown' : b.toString().split('.').last),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _bloodGroup = v),
                ),
              ],
            ),
            CustomTextField(controller: _heightController, label: 'Height (cm)', keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            CustomTextField(controller: _weightController, label: 'Weight (kg)', keyboardType: TextInputType.number),
            const SizedBox(height: 8),
            CustomTextField(controller: _allergiesController, label: 'Allergies (comma separated)'),
            const SizedBox(height: 8),
            CustomTextField(controller: _medicationsController, label: 'Medications (comma separated)'),
            const SizedBox(height: 8),
            CustomTextField(controller: _chronicController, label: 'Chronic Conditions (comma separated)'),
            const SizedBox(height: 8),
            CustomTextField(controller: _emergencyContactController, label: 'Emergency Contact'),
            const SizedBox(height: 8),
            CustomTextField(controller: _emergencyPhoneController, label: 'Emergency Contact Phone'),
            const SizedBox(height: 8),
            CustomTextField(controller: _insuranceProviderController, label: 'Insurance Provider'),
            const SizedBox(height: 8),
            CustomTextField(controller: _insuranceNumberController, label: 'Insurance Number'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: Text(widget.member == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }

  void _onSave() async {
    final provider = widget.provider;
    final member = widget.member;
    final newMember = FamilyMemberModel(
      id: member?.id ?? '',
      primaryUserId: member?.primaryUserId ?? '',
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      dateOfBirth: _dateOfBirth,
      gender: _gender,
      relationship: _relationship,
      bloodGroup: _bloodGroup,
      height: double.tryParse(_heightController.text.trim()),
      weight: double.tryParse(_weightController.text.trim()),
      allergies: _allergiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      chronicConditions: _chronicController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      medications: _medicationsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
      emergencyContact: _emergencyContactController.text.trim().isEmpty ? null : _emergencyContactController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim().isEmpty ? null : _emergencyPhoneController.text.trim(),
      insuranceProvider: _insuranceProviderController.text.trim().isEmpty ? null : _insuranceProviderController.text.trim(),
      insuranceNumber: _insuranceNumberController.text.trim().isEmpty ? null : _insuranceNumberController.text.trim(),
      profileImage: member?.profileImage,
      isActive: true,
      createdAt: member?.createdAt ?? DateTime.now(),
      updatedAt: member != null ? DateTime.now() : null,
    );
    bool success;
    if (member == null) {
      success = await provider.addFamilyMember(newMember);
    } else {
      success = await provider.updateFamilyMember(newMember);
    }
    if (success && mounted) Navigator.of(context).pop();
  }
} 
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

class AccountSettingsScreen extends StatefulWidget {
  final String initialName;
  final String phoneNumber;
  final String? initialDateOfBirth;

  const AccountSettingsScreen({
    super.key,
    required this.initialName,
    required this.phoneNumber,
    this.initialDateOfBirth,
  });

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _phoneController = TextEditingController(text: widget.phoneNumber);
    _dobController = TextEditingController();
    _dobController = TextEditingController(text: widget.initialDateOfBirth ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newDob = _dobController.text.trim();

    if (newName.isEmpty || newPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and phone number cannot be empty')),
      );
      return;
    }

    final updatedUser = UserModel(
      id: newPhone,
      name: newName,
      phoneNumber: newPhone,
      dateOfBirth: newDob.isEmpty ? null : newDob,
    );

    await AuthService().updateCurrentUser(updatedUser);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: Colors.green),
    );
    
    Navigator.pop(context, true); 
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    Widget? suffixIcon,
    bool readOnly = false,
    VoidCallback? onTap,
    String? hintText,
  }) {

    final isLocked = readOnly && onTap == null;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          color: isLocked ? Colors.grey.shade400 : Colors.black87,
          fontSize: 16
        ),
        decoration: InputDecoration(
          labelText: label.isEmpty ? null : label,
          labelStyle: const TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w600),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 16),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: label.isEmpty ? 14 : 8),
          suffixIcon: suffixIcon,
          suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade300,
              child: Icon(Icons.person, size: 60, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt, color: Colors.blue, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'Add a Profile Photo',
                    style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildCustomTextField(
              label: 'Name and Surname',
              controller: _nameController,
            ),

            _buildCustomTextField(
              label: 'Phone Number',
              controller: _phoneController,
              readOnly: true,
            ),
            
            _buildCustomTextField(
              label: '',
              hintText: 'Date of Birth',
              controller: _dobController,
              readOnly: true,
              onTap: () => _selectDate(context),
              suffixIcon: const Icon(Icons.calendar_month, color: Colors.grey),
            ),

            const SizedBox(height: 40),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, 
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  onPressed: _saveProfile,
                  child: const Text(
                    'Save',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            TextButton(
              onPressed: () {},
              child: const Text(
                'Manage Account',
                style: TextStyle(color: Colors.blue, fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

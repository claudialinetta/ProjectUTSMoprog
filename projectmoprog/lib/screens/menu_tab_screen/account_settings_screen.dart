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

    if (newName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }

    try {
      final updatedUser = UserModel(
        id: widget.phoneNumber,
        name: newName,
        phoneNumber: newPhone,
        dateOfBirth: newDob.isEmpty ? null : newDob,
      );
      await AuthService().updateCurrentUser(updatedUser);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildCustomTextField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
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
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade300
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(
          color: isLocked 
              ? Colors.grey.shade500 
              : (isDark ? Colors.white : Colors.black87),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label.isEmpty ? null : label,
          labelStyle: TextStyle(
            color: isDark ? Colors.blue.shade300 : Colors.blue, 
            fontSize: 14, 
            fontWeight: FontWeight.w600,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
            ),
            child: Icon(
              Icons.arrow_back_ios_new, 
              color: isDark ? Colors.white : Colors.black87, 
              size: 16,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Account Settings',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87, 
            fontSize: 18, 
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 24),
            CircleAvatar(
              radius: 50,
              backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade300,
              child: Icon(
                Icons.person, 
                size: 60, 
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? Colors.blue.withValues(alpha: 0.15) : Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.camera_alt, 
                    color: isDark ? Colors.blue.shade300 : Colors.blue, 
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add a Profile Photo',
                    style: TextStyle(
                      color: isDark ? Colors.blue.shade300 : Colors.blue.shade700, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            _buildCustomTextField(
              label: 'Name and Username',
              controller: _nameController,
              isDark: isDark,
            ),

            _buildCustomTextField(
              label: 'Phone Number',
              controller: _phoneController,
              readOnly: true,
              isDark: isDark,
            ),
            
            _buildCustomTextField(
              label: '',
              hintText: 'Date of Birth',
              controller: _dobController,
              readOnly: true,
              isDark: isDark,
              onTap: () => _selectDate(context),
              suffixIcon: Icon(
                Icons.calendar_month, 
                color: isDark ? Colors.grey.shade400 : Colors.grey,
              ),
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
                    style: TextStyle(
                      fontSize: 18, 
                      color: Colors.white, 
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            TextButton(
              onPressed: () {},
              child: Text(
                'Manage Account',
                style: TextStyle(
                  color: isDark ? Colors.blue.shade300 : Colors.blue, 
                  fontSize: 16, 
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

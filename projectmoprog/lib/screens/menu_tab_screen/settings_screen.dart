import 'package:flutter/material.dart';
import 'account_settings_screen.dart';
import '../../theme/theme_manager.dart';

class SettingsScreen extends StatefulWidget {
  final String userName;
  final String phoneNumber;
  final String? dateOfBirth;

  const SettingsScreen({
    super.key,
    required this.userName,
    required this.phoneNumber,
    this.dateOfBirth,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedThemeIndex = 0;

  @override
  void initState() {
    super.initState();
    final currentTheme = ThemeManager.themeModeNotifier.value;
    if (currentTheme == ThemeMode.dark) {
      _selectedThemeIndex = 1;
    } else {
      _selectedThemeIndex = 0;
    }
  }

  Widget _buildThemeButton(IconData icon, int index, bool isDark) {
    final isSelected = _selectedThemeIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedThemeIndex = index);
          ThemeManager.changeTheme(index);
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isDark ? Colors.grey.shade700 : Colors.white) 
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Icon(
              icon,
              color: isSelected 
                  ? (isDark ? Colors.white : Colors.black87) 
                  : Colors.grey.shade500,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(
          'Settings', 
          style: TextStyle(
            fontSize: 18, 
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.5,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              shape: BoxShape.circle, 
              color: isDark ? Colors.grey.shade800 : Colors.white,
            ),
            child: Icon(
              Icons.arrow_back_ios_new, 
              size: 16, 
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme Picker',
              style: TextStyle(
                fontSize: 14, 
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, 
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  _buildThemeButton(Icons.wb_sunny_outlined, 0, isDark),
                  _buildThemeButton(Icons.nightlight_outlined, 1, isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'General',
              style: TextStyle(
                fontSize: 14, 
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, 
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      'Account Settings', 
                      style: TextStyle(
                        fontSize: 15, 
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios, 
                      size: 14, 
                      color: isDark ? Colors.white54 : Colors.grey,
                    ),
                    onTap: () async {
                      final updated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountSettingsScreen(
                            initialName: widget.userName,
                            phoneNumber: widget.phoneNumber,
                            initialDateOfBirth: widget.dateOfBirth,
                          ),
                        ),
                      );
                      if (updated == true && context.mounted) {
                        Navigator.pop(context, true);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
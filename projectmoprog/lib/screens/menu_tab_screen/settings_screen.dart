import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'account_settings_screen.dart';
import '../../providers/theme_provider.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../auth_screens/login_screen.dart';

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
  final Duration _animDuration = const Duration(milliseconds: 300);

  bool _notificationsEnabled = true;
  String get currentUserId => widget.phoneNumber;

  @override
  void initState() {
    super.initState();
    _loadNotifStatus();
  }

  Future<void> _loadNotifStatus() async {
    final status = await NotificationService().isNotificationsEnabled(currentUserId);
    if (mounted) {
      setState(() {
        _notificationsEnabled = status;
      });
    }
  }

  Widget _buildThemePreviewCard({
    required String title,
    required bool isDarkPreview,
    required bool isSelected,
    required bool isDarkTheme,
    required BuildContext context,
  }) {
    final previewBg = isDarkPreview
        ? const Color(0xFF121212)
        : const Color(0xFFF4F6F9);
    final previewCard = isDarkPreview ? const Color(0xFF1E1E1E) : Colors.white;
    final previewElement = isDarkPreview
        ? Colors.grey.shade700
        : Colors.grey.shade300;
    final primaryColor = isDarkPreview ? Colors.blue.shade300 : Colors.blue;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<ThemeProvider>().setTheme(
            isDarkPreview ? ThemeMode.dark : ThemeMode.light,
          );
        },
        child: Column(
          children: [
            AnimatedContainer(
              duration: _animDuration,
              width: 120,
              height: 220,
              decoration: BoxDecoration(
                color: previewBg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? Colors.blue
                      : (isDarkTheme
                            ? Colors.grey.shade800
                            : Colors.grey.shade300),
                  width: isSelected ? 2.5 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 20,
                      left: 14,
                      right: 14,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.arrow_back_ios_new,
                          size: 10,
                          color: previewElement,
                        ),
                        Container(
                          width: 32,
                          height: 5,
                          decoration: BoxDecoration(
                            color: previewElement,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  CircleAvatar(radius: 16, backgroundColor: previewCard),
                  const SizedBox(height: 12),
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: previewElement,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: previewCard,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 14),
                          Container(
                            width: 60,
                            height: 5,
                            decoration: BoxDecoration(
                              color: previewElement,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            width: 35,
                            height: 5,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDarkTheme ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 14),

            AnimatedContainer(
              duration: _animDuration,
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? Colors.blue : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? Colors.blue
                      : (isDarkTheme
                            ? Colors.grey.shade600
                            : Colors.grey.shade400),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService().logout();

      if (!context.mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to log out: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedThemeIndex = themeProvider.themeMode == ThemeMode.dark
        ? 1
        : (themeProvider.themeMode == ThemeMode.light ? 0 : (isDark ? 1 : 0));

    final hoverColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.grey.shade200;
    final splashColor = isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.grey.shade300;
    final dividerColor = isDark
        ? const Color(0xFF2C2C2C)
        : Colors.grey.shade200;

    return AnimatedContainer(
      duration: _animDuration,
      color: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: AnimatedDefaultTextStyle(
            duration: _animDuration,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
            child: const Text('Settings'),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0.5,
          leading: IconButton(
            icon: AnimatedSwitcher(
              duration: _animDuration,
              child: Icon(
                Icons.arrow_back_ios_new,
                key: ValueKey<bool>(isDark),
                size: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: _animDuration,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                      child: const Text('Theme'),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildThemePreviewCard(
                          title: 'Light',
                          isDarkPreview: false,
                          isSelected: selectedThemeIndex == 0,
                          isDarkTheme: isDark,
                          context: context,
                        ),
                        const SizedBox(width: 48),
                        _buildThemePreviewCard(
                          title: 'Dark',
                          isDarkPreview: true,
                          isSelected: selectedThemeIndex == 1,
                          isDarkTheme: isDark,
                          context: context,
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                    AnimatedDefaultTextStyle(
                      duration: _animDuration,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                      child: const Text('General'),
                    ),

                    const SizedBox(height: 8),
                    Container(
                      margin: const EdgeInsets.all(4),
                      child: Material(
                        animationDuration: _animDuration,
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            ListTile(
                              hoverColor: hoverColor,
                              splashColor: splashColor,
                              title: AnimatedDefaultTextStyle(
                                duration: _animDuration,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                child: const Text('Account Settings'),
                              ),
                              trailing: AnimatedSwitcher(
                                duration: _animDuration,
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  key: ValueKey<bool>(isDark),
                                  size: 14,
                                  color: isDark ? Colors.white54 : Colors.grey,
                                ),
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

                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: dividerColor,
                            ),

                            ListTile(
                              hoverColor: hoverColor,
                              splashColor: splashColor,
                              title: AnimatedDefaultTextStyle(
                                duration: _animDuration,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white : Colors.black87,
                                ),
                                child: const Text('Notifications'),
                              ),
                              trailing: Switch(
                                value: _notificationsEnabled,
                                activeThumbColor: Colors.blue,
                                onChanged: (value) async {
                                  setState(() {
                                    _notificationsEnabled = value;
                                  });
                                  // Simpan langsung ke database Supabase berdasarkan akun user!
                                  await NotificationService().setNotificationsEnabled(currentUserId, value);
                                },
                              ),
                              onTap: () async {
                                final newValue = !_notificationsEnabled;
                                setState(() {
                                  _notificationsEnabled = newValue;
                                });
                                await NotificationService()
                                    .setNotificationsEnabled(currentUserId, newValue);
                              },
                            ),

                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: dividerColor,
                            ),

                            ListTile(
                              hoverColor: hoverColor,
                              splashColor: splashColor,
                              leading: const Icon(
                                Icons.logout,
                                color: Colors.redAccent,
                              ),
                              title: const Text(
                                'Log Out',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.redAccent,
                                ),
                              ),
                              onTap: () => _logout(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 35),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

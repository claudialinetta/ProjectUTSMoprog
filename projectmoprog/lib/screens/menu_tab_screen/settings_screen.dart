import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'account_settings_screen.dart';
import '../../providers/theme_provider.dart';

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
  // Durasi transisi seragam untuk semua animasi
  final Duration _animDuration = const Duration(milliseconds: 300);

  Widget _buildThemeButton({
    required IconData icon,
    required int index,
    required bool isSelected,
    required bool isDark,
  }) {
    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            context.read<ThemeProvider>().setTheme(
              index == 1 ? ThemeMode.dark : ThemeMode.light,
            );
          },
          child: AnimatedContainer(
            duration: _animDuration,
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
              child: AnimatedSwitcher(
                duration: _animDuration,
                child: Icon(
                  icon,
                  key: ValueKey<bool>(isDark),
                  color: isSelected 
                      ? (isDark ? Colors.white : Colors.black87) 
                      : Colors.grey.shade500,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
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

    return AnimatedContainer(
      duration: _animDuration,
      color: isDark ? const Color(0xFF121212) : Colors.grey.shade100,
      child: Scaffold(
        backgroundColor: Colors.transparent, // Mengikuti warna AnimatedContainer di atasnya
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: _animDuration,
                style: TextStyle(
                  fontSize: 14, 
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, 
                  fontWeight: FontWeight.w600,
                ),
                child: const Text('Theme Picker'),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: _animDuration,
                height: 48,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey.shade900 : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    _buildThemeButton(
                      icon: Icons.wb_sunny_outlined,
                      index: 0,
                      isSelected: selectedThemeIndex == 0,
                      isDark: isDark,
                    ),
                    _buildThemeButton(
                      icon: Icons.nightlight_outlined,
                      index: 1,
                      isSelected: selectedThemeIndex == 1,
                      isDark: isDark,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AnimatedDefaultTextStyle(
                duration: _animDuration,
                style: TextStyle(
                  fontSize: 14, 
                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600, 
                  fontWeight: FontWeight.w600,
                ),
                child: const Text('General'),
              ),
              const SizedBox(height: 8),
              // Mengubah Card statis menjadi AnimatedContainer untuk efek smooth
              AnimatedContainer(
                duration: _animDuration,
                margin: const EdgeInsets.all(4), // Mempertahankan margin bawaan dari widget Card sebelumnya
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Material(
                  color: Colors.transparent,
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
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

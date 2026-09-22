import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../models/user_model.dart';
import 'menu_tab_screen/account_settings_screen.dart';
import 'menu_tab_screen/settings_screen.dart';
import '../widgets/menu_item_tile.dart';
import 'auth_screens/login_screen.dart';

class MenuScreen extends StatefulWidget {
  final String currentUserId;

  const MenuScreen({super.key, required this.currentUserId});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {  
  String _userName = "Loading...";
  String _userInitial = "-";
  String? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final UserModel? user = await AuthService().getCurrentUser();
      
      if (mounted) {
        setState(() {
          if (user != null) {
            _userName = user.name;
            _userInitial = user.name.isNotEmpty ? user.name[0].toUpperCase() : "?";
            _dateOfBirth = user.dateOfBirth;
          } else {
            _userName = "GetContact User";
            _userInitial = "G";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = "Failed to load.";
          _userInitial = "?";
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    await AuthService().logout();

    if (!context.mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: SafeArea(
        top: true,
        child: ListView(
          physics: const ClampingScrollPhysics(),
          padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      _userInitial,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userName,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B)
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.currentUserId,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            if (_dateOfBirth == null || _dateOfBirth!.isEmpty) ...[
              MenuGroupCard(
                children: [
                  MenuItemTile(
                    icon: Icons.cake_outlined,
                    title: 'Add Your Birthday!',
                    subtitle: 'Add your birthday for celebrations, congratulations, and gifts.',
                    onTap: () async {
                      final bool? isUpdated = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountSettingsScreen(
                            initialName: _userName,
                            phoneNumber: widget.currentUserId,
                            initialDateOfBirth: _dateOfBirth,
                          ),
                        ),
                      );

                      if (isUpdated == true) {
                        _fetchUserProfile();
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            MenuGroupCard(
              children: [
                MenuItemTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifications',
                  showDivider: true,
                  onTap: () {},
                ),
                MenuItemTile(
                  icon: Icons.remove_red_eye_outlined,
                  title: 'Who Viewed My Profile',
                  trailing: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 4, backgroundColor: Colors.red),
                      SizedBox(width: 6),
                      Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 22),
                    ],
                  ),
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),
            
            MenuGroupCard(
              children: [
                MenuItemTile(
                  icon: Icons.grid_view_rounded,
                  title: 'Shortcuts',
                  showDivider: true,
                  onTap: () {},
                ),
                MenuItemTile(
                  icon: Icons.mark_email_unread_rounded,
                  title: 'Spam SMS Protection',
                  showDivider: true,
                  onTap: () {},
                ),
                MenuItemTile(
                  icon: Icons.phone_disabled_rounded,
                  title: 'Spam Call Settings',
                  showDivider: true,
                  onTap: () {},
                ),
              ],
            ),

            const SizedBox(height: 16),

            MenuGroupCard(
              children: [
                SimpleMenuTile(
                  icon: Icons.workspace_premium_outlined,
                  title: 'Premium and Plans',
                  onTap: () {},
                ),
                SimpleMenuTile(
                  icon: Icons.pie_chart_outline_rounded,
                  title: 'Usage Limits',
                  onTap: () {},
                ),
                SimpleMenuTile(
                  icon: Icons.public_rounded,
                  title: 'Getcontact Web',
                  onTap: () {},
                ),
                SimpleMenuTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Community / Help',
                  onTap: () {},
                ),
                SimpleMenuTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'Comments',
                  onTap: () {},
                ),
                SimpleMenuTile(
                  icon: Icons.sms_outlined,
                  title: 'WhatsApp Bot',
                  onTap: () {},
                ),
                SimpleMenuTile(
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  showDivider: false, 
                  onTap: () async {
                    final bool? isUpdated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SettingsScreen(
                          userName: _userName,
                          phoneNumber: widget.currentUserId,
                          dateOfBirth: _dateOfBirth,
                        ),
                      ),
                    );

                    if (isUpdated == true) {
                      _fetchUserProfile();
                    }
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';

import 'menu_features_screens/contact_screen.dart';
import 'menu_features_screens/my_tags_screen.dart';
import 'menu_features_screens/call_history_screen.dart';
import 'menu_features_screens/protection_stats_screen.dart';
import 'menu_features_screens/help_center_screen.dart';

class HomeScreen extends StatelessWidget {
  final String currentUserId;
  final String currentUserPhoneNumber;

  const HomeScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserPhoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(title: const Text("GetContact Clone"), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Home",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              _buildMenuCard(
                context: context,
                title: "Check My Tags",
                subtitle: "Check what other people saved your name",
                icon: Icons.tag,
                color: Colors.blue.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyTagsScreen(
                        currentUserPhoneNumber: currentUserPhoneNumber,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildMenuCard(
                context: context,
                title: "Contacts",
                subtitle: "All your contacts inside one place",
                icon: Icons.search,
                color: Colors.teal.shade600,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ContactScreen(currentUserId: currentUserId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildMenuCard(
                context: context,
                title: "Call History",
                subtitle: "View your recent contact history",
                icon: Icons.history,
                color: Colors.orange.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CallHistoryScreen(ownerId: currentUserId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildMenuCard(
                context: context,
                title: "Protection Stats",
                subtitle: "See how you stay protected and help others",
                icon: Icons.shield_outlined,
                color: Colors.green.shade700,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ProtectionStatsScreen(ownerId: currentUserId),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              _buildMenuCard(
                context: context,
                title: "Help Center",
                subtitle: "Find guides and FAQs",
                icon: Icons.help_outline,
                color: Colors.purple.shade600,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpCenterScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

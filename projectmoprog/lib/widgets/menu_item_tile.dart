import 'package:flutter/material.dart';

class MenuGroupCard extends StatelessWidget {
  final List<Widget> children;

  const MenuGroupCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        border: Border.symmetric(
          horizontal: BorderSide(
            color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE9ECEF), 
            width: 0.8,
          ),
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class MenuItemTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showDivider;

  const MenuItemTile({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
    this.showDivider = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Menyiapkan warna dinamis
    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final iconBgColor = isDark ? Colors.blue.withValues(alpha: 0.15) : const Color(0xFFEDF4FF);
    final iconColor = isDark ? Colors.blue : const Color(0xFF007AFF);
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final subtitleColor = isDark ? Colors.grey.shade400 : const Color(0xFF8A94A6);
    final trailingColor = isDark ? Colors.grey.shade600 : const Color(0xFFCBD5E1);
    final dividerColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9);

    return Column(
      children: [
        Material(
          color: bgColor,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w600,
                            color: titleColor,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            subtitle!,
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor,
                              height: 1.25,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  trailing ?? Icon(Icons.chevron_right_rounded, color: trailingColor, size: 22),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.6,
            indent: 74, 
            color: dividerColor,
          ),
      ],
    );
  }
}

class SimpleMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const SimpleMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final iconColor = isDark ? Colors.blue : const Color(0xFF007AFF);
    final titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final dividerColor = isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF1F5F9);

    return Column(
      children: [
        Material(
          color: bgColor,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
              child: Row(
                children: [
                  Icon(icon, color: iconColor, size: 24),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: titleColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.6,
            indent: 56, 
            color: dividerColor,
          ),
      ],
    );
  }
}

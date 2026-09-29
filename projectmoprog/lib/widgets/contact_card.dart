import 'package:flutter/material.dart';

import '../models/contact_model.dart';
import 'tag_badge.dart';

class ContactCard extends StatelessWidget {
  final ContactModel contact;
  final VoidCallback? onTap;
  final Function(String reason)? onReport;

  const ContactCard({
    super.key,
    required this.contact,
    this.onReport,
    this.onTap,
  });

  void _showConfirmReportDialog(
    BuildContext reportDialogCtx,
    String reason,
    IconData reasonIcon,
    Color reasonColor,
  ) {
    final bool isDark = Theme.of(reportDialogCtx).brightness == Brightness.dark;
    final Color dialogBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    showDialog(
      context: reportDialogCtx,
      builder: (confirmCtx) {
        return Dialog(
          backgroundColor: dialogBgColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: Colors.redAccent,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Confirm Report",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13.5,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(text: "Are you sure you want to report "),
                      TextSpan(
                        text: contact.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const TextSpan(text: " for "),
                      TextSpan(
                        text: reason,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      const TextSpan(text: "?"),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                          ),
                        ),
                        onPressed: () => Navigator.pop(confirmCtx),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(confirmCtx);
                          Navigator.pop(reportDialogCtx);
                          if (onReport != null) {
                            onReport!(reason);
                          }
                        },
                        child: const Text(
                          "Yes, Report",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color dialogBgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final Color titleColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final Color cardItemBg = isDark ? const Color(0xFF262626) : const Color(0xFFF8FAFC);
    final Color cardItemBorder = isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0);

    final List<Map<String, dynamic>> reportReasons = [
      {
        'title': 'Fraud / Scam',
        'subtitle': 'Money scams, fake prizes, or phishing',
        'icon': Icons.gpp_bad_outlined,
        'color': Colors.redAccent,
      },
      {
        'title': 'Spam Calls / Robocalls',
        'subtitle': 'Automated or repeated phone calls',
        'icon': Icons.phone_disabled_outlined,
        'color': Colors.orangeAccent,
      },
      {
        'title': 'Telemarketing',
        'subtitle': 'Unwanted product, insurance, or loan offers',
        'icon': Icons.campaign_outlined,
        'color': Colors.amber.shade700,
      },
      {
        'title': 'Threats / Harassment',
        'subtitle': 'Verbal threats, harassment, or intimidation',
        'icon': Icons.front_hand_outlined,
        'color': Colors.deepOrangeAccent,
      },
      {
        'title': 'Fake Number',
        'subtitle': 'False identity or an invalid phone number',
        'icon': Icons.no_accounts_outlined,
        'color': Colors.purpleAccent,
      },
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: dialogBgColor,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.flag_rounded,
                          color: Colors.redAccent,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Report Contact",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              contact.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Select a reason for reporting to help protect other users.",
                    style: TextStyle(
                      fontSize: 12.5,
                      color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...reportReasons.map((item) {
                    final String title = item['title'] as String;
                    final String subtitle = item['subtitle'] as String;
                    final IconData icon = item['icon'] as IconData;
                    final Color color = item['color'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: cardItemBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cardItemBorder, width: 0.8),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            _showConfirmReportDialog(ctx, title, icon, color);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(icon, color: color, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        subtitle,
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right_rounded,
                                  size: 18,
                                  color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isSpam =
        contact.reportCount >= 10 || contact.tag == 'Spam Likely';

    return Card(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0.5,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFE9ECEF),
          width: 0.8,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: isSpam ? Colors.red.shade100 : Colors.blue.shade100,
          child: Text(
            contact.avatarInitial,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSpam ? Colors.red.shade900 : Colors.blue.shade900,
            ),
          ),
        ),
        title: Text(
          contact.name,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              contact.phoneNumber,
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
            if (contact.reportCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 13,
                      color: isSpam ? Colors.red : Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${contact.reportCount} ${contact.reportCount == 1 ? 'Report' : 'Reports'}",
                      style: TextStyle(
                        fontSize: 11,
                        color: isSpam ? Colors.red : Colors.orange.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TagBadge(tag: contact.tag),
            IconButton(
              icon: Icon(
                Icons.flag_outlined,
                size: 20,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              ),
              tooltip: 'Report Contact',
              onPressed: () => _showReportDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

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

  void _showReportDialog(BuildContext context) {
    final List<String> reasons = [
      'Fraud / Scam',
      'Spam Calls / Robocalls',
      'Annoying Telemarketing',
      'Threats / Harassment',
      'Fake Number',
    ];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Report ${contact.name}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Select a reason for reporting to help protect other users:",
                style: TextStyle(color: Colors.grey),
              ),
              const Divider(height: 24),
              ...reasons.map(
                (reason) => ListTile(
                  leading: const Icon(
                    Icons.report_problem_outlined,
                    color: Colors.redAccent,
                  ),
                  title: Text(reason),
                  onTap: () {
                    Navigator.pop(ctx);
                    if (onReport != null) {
                      onReport!(reason);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSpam =
        contact.reportCount >= 10 || contact.tag == 'Spam Likely';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(contact.phoneNumber),
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
                      "${contact.reportCount} laporan",
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
              icon: const Icon(
                Icons.flag_outlined,
                size: 20,
                color: Colors.grey,
              ),
              tooltip: 'Laporkan Kontak',
              onPressed: () => _showReportDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

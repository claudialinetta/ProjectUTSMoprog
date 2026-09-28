class ProtectionStats {
  final int numbersChecked;
  final int spamAvoided;
  final int reportsGiven;

  const ProtectionStats({
    required this.numbersChecked,
    required this.spamAvoided,
    required this.reportsGiven,
  });

  const ProtectionStats.empty()
    : numbersChecked = 0,
      spamAvoided = 0,
      reportsGiven = 0;
}

class ProtectionActivity {
  final String message;
  final DateTime createdAt;

  const ProtectionActivity({required this.message, required this.createdAt});

  factory ProtectionActivity.fromMap(Map<String, dynamic> map) {
    return ProtectionActivity(
      message: (map['message'] as String?) ?? 'Activity',
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}

class ReportHistoryEntry {
  final String contactName;
  final String phoneNumber;
  final String reason;
  final DateTime createdAt;

  const ReportHistoryEntry({
    required this.contactName,
    required this.phoneNumber,
    required this.reason,
    required this.createdAt,
  });

  factory ReportHistoryEntry.fromMap(Map<String, dynamic> map) {
    return ReportHistoryEntry(
      contactName: (map['contact_name'] as String?) ?? 'Unknown',
      phoneNumber: (map['phone_number'] as String?) ?? '-',
      reason: (map['reason'] as String?) ?? 'Other',
      createdAt:
          DateTime.tryParse(map['created_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}

class DailyActivity {
  final DateTime day;
  final int count;

  const DailyActivity({required this.day, required this.count});
}

class CheckEntry {
  final String name;
  final String phoneNumber;
  final DateTime checkedAt;

  const CheckEntry({
    required this.name,
    required this.phoneNumber,
    required this.checkedAt,
  });

  factory CheckEntry.fromMap(Map<String, dynamic> map) {
    return CheckEntry(
      name: (map['name'] as String?) ?? 'Unknown',
      phoneNumber: (map['phone_number'] as String?) ?? '-',
      checkedAt:
          DateTime.tryParse(map['checked_at']?.toString() ?? '')?.toLocal() ??
          DateTime.now(),
    );
  }
}

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

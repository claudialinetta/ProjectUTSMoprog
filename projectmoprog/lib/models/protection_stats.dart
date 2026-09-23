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

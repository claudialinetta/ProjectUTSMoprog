class ContactTag {
  final String label;
  final String addedByName;
  final DateTime addedAt;

  ContactTag({
    required this.label,
    required this.addedByName,
    DateTime? addedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'label': label,
    'addedByName': addedByName,
    'addedAt': addedAt.toIso8601String(),
  };

  factory ContactTag.fromJson(Map<String, dynamic> json) => ContactTag(
    label: json['label'] as String,
    addedByName: json['addedByName'] as String,
    addedAt: DateTime.parse(json['addedAt'] as String),
  );
}

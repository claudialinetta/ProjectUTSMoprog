enum FaqCategory {
  privacy('Privacy & Contacts'),
  spam('Spam & Report'),
  account('Account & General');

  final String label;
  const FaqCategory(this.label);

  static FaqCategory fromString(String? value) {
    return FaqCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => FaqCategory.account,
    );
  }
}

class FaqItem {
  final String question;
  final String answer;
  final FaqCategory category;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });

  factory FaqItem.fromMap(Map<String, dynamic> map) {
    return FaqItem(
      question: (map['question'] as String?) ?? '',
      answer: (map['answer'] as String?) ?? '',
      category: FaqCategory.fromString(map['category'] as String?),
    );
  }
}

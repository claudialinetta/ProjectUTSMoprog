class SavedContactModel {
  final String id;
  final String phoneNumber;
  final String savedName;
  final String saveBy;

  SavedContactModel({
    required this.id,
    required this.phoneNumber,
    required this.savedName,
    required this.saveBy,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'phoneNumber': phoneNumber,
    'savedName': savedName,
    'saveBy': saveBy,
  };

  factory SavedContactModel.fromJson(Map<String, dynamic> json) => SavedContactModel(
    id: json['id'].toString(),
    phoneNumber: json['phoneNumber'] as String? ?? 'XXX',
    savedName: json['savedName'] as String? ?? 'John Doe',
    saveBy: json['saveBy'] as String? ?? 'Jane Doe',
  );
}
class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String? dateOfBirth;
  bool isPremium;
  bool isProfilePublic;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.dateOfBirth,
    this.isPremium = false,
    this.isProfilePublic = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phoneNumber': phoneNumber,
    'dateOfBirth': dateOfBirth,
    'isPremium': isPremium,
    'isProfilePublic': isProfilePublic,
  };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String,
    name: json['name'] as String,
    phoneNumber: json['phoneNumber'] as String,
    dateOfBirth: json['dateOfBirth'] as String?,
    isPremium: json['isPremium'] as bool? ?? false,
    isProfilePublic: json['isProfilePublic'] as bool? ?? true,
  );
}

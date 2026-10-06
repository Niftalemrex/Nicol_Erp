class UserModel {
  final String id;
  final String name;
  final String role;
  final String status;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'] ?? '',
      role: map['role'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
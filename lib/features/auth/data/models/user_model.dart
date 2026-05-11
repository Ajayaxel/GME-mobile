class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final String initials;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.initials,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      initials: json['initials'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'initials': initials,
    };
  }
}

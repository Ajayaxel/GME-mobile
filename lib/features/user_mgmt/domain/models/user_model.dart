import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String role;
  final String department;
  final String phone;
  final String status;
  final String initials;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.department,
    required this.phone,
    required this.status,
    required this.initials,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'Staff',
      department: json['department'] ?? 'Operations',
      phone: json['phone'] ?? '',
      status: json['status'] ?? 'Active',
      initials: json['initials'] ?? '',
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, name, email, role, department, status];
}
